# ADR 001 — Interdire les appels base de données dans les specs unitaires

**Date** : 2026-06-29
**Statut** : En cours de livraison (branche `no-create-tests-unitaires`, non mergée)
**Cop** : `Captive/RSpec/NoDbInUnitSpecs`

---

## Contexte

Les specs RSpec sont organisées par type de fichier (`spec/models/`, `spec/mailers/`, `spec/lib/`…). En pratique, ces specs mélangent deux natures de tests :

- **Tests unitaires** : testent une classe isolément, sans effet de bord
- **Tests d'intégration** : testent un comportement qui implique la base de données (callbacks, scopes, contraintes d'unicité…)

Ce mélange pose trois problèmes :

1. **Lenteur** : un appel à `FactoryBot.create` ou `Model.create` dans un test unitaire ralentit toute la suite de tests alors que ce n'est pas nécessaire.
2. **Couplage caché** : `FactoryBot.build` avec associations sauve quand même les associations en BDD, ce qui crée des effets de bord invisibles.
3. **Signal faible** : quand tous les tests touchent la BDD, on perd la capacité de distinguer ce qui est vraiment unitaire.

## Décision

Ajouter le cop RuboCop `Captive/RSpec/NoDbInUnitSpecs` qui interdit tout appel base de données dans les specs qui ne sont pas explicitement des specs d'intégration.

**Méthodes interdites** :

- `FactoryBot.create` / `create` / `create_list` / `create_pair`
- `FactoryBot.build` / `build` / `build_list` / `build_pair`
- `FactoryBot.build_stubbed` / `build_stubbed` / `build_stubbed_list`
- `Const.create` / `Const.create!` (toute constante)
- `obj.save` / `obj.save!`

**Dossiers autorisés** (BDD permise) :

- `spec/requests`, `spec/system`, `spec/features`, `spec/integration`
- `spec/services`, `spec/jobs`, `spec/support`, `spec/factories`

**Dossiers soumis au cop** (BDD interdite) :

- `spec/models`, `spec/mailers`, `spec/lib`, et tout autre dossier non listé ci-dessus

**Alternatives recommandées** :

- `instance_double` pour mocker une dépendance
- `Model.new` pour instancier sans persister
- Déplacer dans `spec/integration` si le test porte sur un scope ou une contrainte BDD

## Pourquoi interdire `build` et `build_stubbed` ?

`FactoryBot.build` ne persiste pas l'objet principal, mais **crée en BDD les associations** définies dans la factory (`association :user` → `create(:user)`). Ce comportement est silencieux et contre-intuitif.

`FactoryBot.build_stubbed` évite la BDD mais reste une abstraction FactoryBot qui cache les valeurs par défaut et masque les intentions du test. Dans un vrai test unitaire, `Model.new(attr: value)` est préférable car il documente explicitement les attributs testés.

## Conséquences

- Les specs existantes génèrent des offenses (551 détectées sur `cae/serveur` lors du diagnostic initial).
- La dette est à résorber progressivement via `rubocop_todo.yml` sur chaque projet, puis en migrant les tests concernés vers `instance_double`, `Model.new`, ou `spec/integration`.
- Les nouveaux fichiers de spec sont soumis à la règle immédiatement.

## Alternatives envisagées

**Distinction par `require 'spec_helper'` vs `require 'rails_helper'`** : plus standard, mais ne correspond pas aux conventions actuelles des projets Captive où `rails_helper` est utilisé même pour des tests unitaires.

**Liste de dossiers interdits (opt-in)** : moins sûr — tout nouveau dossier de spec échappe à la règle par défaut. La liste blanche (opt-out) est plus étanche.
