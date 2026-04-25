import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/character_entity.dart';
import '../controllers/characters_view_model.dart';
import '../widgets/app_drawer.dart';

/// Página de criação ou edição de personagem
class CharacterCreateView extends StatefulWidget {
  final Character? character;

  const CharacterCreateView({super.key, this.character});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  late final CharactersViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CharacterClass _selectedClass = CharacterClass.poderoso;
  CharacterRarity _selectedRarity = CharacterRarity.prata;
  CharacterAlignment _selectedAlignment = CharacterAlignment.heroi;

  int _level = 1;
  int _stars = 1;
  int _threat = 0;
  int _attack = 0;
  int _health = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();

    if (widget.character != null) {
      final character = widget.character!;
      _nameController.text = character.name;
      _selectedClass = character.characterClass;
      _selectedRarity = character.rarity;
      _selectedAlignment = character.alignment;
      _level = character.level;
      _stars = character.stars;
      _threat = character.threat;
      _attack = character.attack;
      _health = character.health;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.character != null;
    final character =
        (widget.character ??
                Character(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  characterClass: _selectedClass,
                  rarity: _selectedRarity,
                  alignment: _selectedAlignment,
                  level: _level,
                  stars: _stars,
                  threat: _threat,
                  attack: _attack,
                  health: _health,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .copyWith(
              name: _nameController.text.trim(),
              characterClass: _selectedClass,
              rarity: _selectedRarity,
              alignment: _selectedAlignment,
              level: _level,
              stars: _stars,
              threat: _threat,
              attack: _attack,
              health: _health,
              updatedAt: DateTime.now(),
            );

    if (isEditing) {
      await _viewModel.commands.updateCharacter(character);
    } else {
      await _viewModel.commands.addCharacter(character);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? '${character.name} atualizado'
                : '${character.name} criado',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.character != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Personagem' : 'Criar Personagem'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCharacter),
        ],
      ),
      drawer: AppDrawer(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Nome é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CharacterClass>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: 'Classe'),
              items: CharacterClass.values.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.displayName));
              }).toList(),
              onChanged: (value) => setState(() => _selectedClass = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CharacterRarity>(
              value: _selectedRarity,
              decoration: const InputDecoration(labelText: 'Raridade'),
              items: CharacterRarity.values.map((r) {
                return DropdownMenuItem(value: r, child: Text(r.displayName));
              }).toList(),
              onChanged: (value) => setState(() => _selectedRarity = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CharacterAlignment>(
              value: _selectedAlignment,
              decoration: const InputDecoration(labelText: 'Alinhamento'),
              items: CharacterAlignment.values.map((a) {
                return DropdownMenuItem(value: a, child: Text(a.displayName));
              }).toList(),
              onChanged: (value) => setState(() => _selectedAlignment = value!),
            ),
            const SizedBox(height: 16),
            Text('Nível: $_level'),
            Slider(
              value: _level.toDouble(),
              min: 1,
              max: 80,
              divisions: 79,
              onChanged: (value) => setState(() => _level = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text('Estrelas: $_stars'),
            Slider(
              value: _stars.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              onChanged: (value) => setState(() => _stars = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text('Ameaça: $_threat'),
            Slider(
              value: _threat.toDouble(),
              min: 0,
              max: 1000,
              onChanged: (value) => setState(() => _threat = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text('Ataque: $_attack'),
            Slider(
              value: _attack.toDouble(),
              min: 0,
              max: 1000,
              onChanged: (value) => setState(() => _attack = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text('Vida: $_health'),
            Slider(
              value: _health.toDouble(),
              min: 0,
              max: 1000,
              onChanged: (value) => setState(() => _health = value.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
