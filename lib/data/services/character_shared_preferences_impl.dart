import 'dart:convert';

import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import 'character_local_storage_interface.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/patterns/result.dart';
import 'package:collection/collection.dart';

final class CharacterSharedPreferencesService
    implements ICharacterLocalStorage {
  // Chave de armazenamento para os personagens
  static const String _storageKey = 'characters';

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final characterToDelete = characters.firstWhereOrNull(
            (c) => c.id == id,
          );
          if (characterToDelete == null) {
            return Error(DefaultFailure('Personagem não encontrado'));
          }
          final updatedCharacters = characters
              .where((c) => c.id != id)
              .toList();
          await _saveCharacters(updatedCharacters);
          return Success(characterToDelete);
        },
        onFailure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao deletar personagem: $e'));
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(_storageKey);

      if (result == null || result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    try {
      final currentResult = await getAllCharacters();

      return currentResult.fold(
        onSuccess: (characters) {
          final character = characters.firstWhereOrNull((c) => c.id == id);
          if (character == null) {
            return Error(DefaultFailure('Personagem não encontrado'));
          }
          return Success(character);
        },
        onFailure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao obter personagem: $e'));
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if (failure is EmptyResultFailure) {
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure());
        },
      );
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters.indexWhere((c) => c.id == character.id);
          if (index == -1) {
            return Error(
              DefaultFailure('Personagem não encontrado para atualização'),
            );
          }
          final updatedCharacters = [...characters];
          updatedCharacters[index] = character;
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar personagem: $e'));
    }
  }

  /// Salva os personagens no storage
  Future<void> _saveCharacters(List<Character> characters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}
