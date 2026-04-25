import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/character_entity.dart';
import '../controllers/characters_view_model.dart';
import '../widgets/app_drawer.dart';

/// Página de edição de personagem
class CharacterEditView extends StatefulWidget {
  final Character character;

  const CharacterEditView({super.key, required this.character});

  @override
  State<CharacterEditView> createState() => _CharacterEditViewState();
}

class _CharacterEditViewState extends State<CharacterEditView> {
  late final CharactersViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late CharacterClass _selectedClass;
  late CharacterRarity _selectedRarity;
  late CharacterAlignment _selectedAlignment;

  late int _level;
  late int _stars;
  late int _threat;
  late int _attack;
  late int _health;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();

    _nameController = TextEditingController(text: widget.character.name);
    _selectedClass = widget.character.characterClass;
    _selectedRarity = widget.character.rarity;
    _selectedAlignment = widget.character.alignment;
    _level = widget.character.level;
    _stars = widget.character.stars;
    _threat = widget.character.threat;
    _attack = widget.character.attack;
    _health = widget.character.health;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateCharacter() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedCharacter = widget.character.copyWith(
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

    await _viewModel.commands.updateCharacter(updatedCharacter);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedCharacter.name} atualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Personagem'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _updateCharacter),
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
