# frozen_string_literal: true

require "spec_helper"

describe RuboCop::Cop::Captive::RSpec::NoDbInUnitSpecs do
  subject(:cop) { described_class.new }

  it "registers an offense for FactoryBot.create in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      FactoryBot.create(:user)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for standalone create in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      create(:user)
      ^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for create_list in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      create_list(:user, 3)
      ^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for FactoryBot.create_list in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      FactoryBot.create_list(:user, 3)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for Const.create in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      User.create(name: "Alice")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for Const.create! in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      User.create!(name: "Alice")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for save on an object in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      user.save
      ^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for save! on an object in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      user.save!
      ^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "does not register an offense for FactoryBot.create in a requests spec" do
    expect_no_offenses(<<~RUBY, "spec/requests/users_spec.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "does not register an offense for FactoryBot.create in a system spec" do
    expect_no_offenses(<<~RUBY, "spec/system/users_spec.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "registers an offense for FactoryBot.build in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      FactoryBot.build(:user)
      ^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for standalone build in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      build(:user)
      ^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for build_list in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      build_list(:user, 3)
      ^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for build_stubbed in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      build_stubbed(:user)
      ^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "registers an offense for build_stubbed_list in a model spec" do
    expect_offense(<<~RUBY, "spec/models/user_spec.rb")
      build_stubbed_list(:user, 3)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Captive/RSpec/NoDbInUnitSpecs: Do not hit the database in unit tests. Use `instance_double` or `Model.new` instead. If testing a scope, move to spec/integration.
    RUBY
  end

  it "does not register an offense for User.new in a model spec" do
    expect_no_offenses(<<~RUBY, "spec/models/user_spec.rb")
      User.new(name: "Alice")
    RUBY
  end

  it "does not register an offense for FactoryBot calls in spec/factories" do
    expect_no_offenses(<<~RUBY, "spec/factories/users.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "does not register an offense for FactoryBot.create in a services spec" do
    expect_no_offenses(<<~RUBY, "spec/services/user_service_spec.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "does not register an offense for FactoryBot.create in a jobs spec" do
    expect_no_offenses(<<~RUBY, "spec/jobs/import_job_spec.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "does not register an offense for FactoryBot.create in spec/support" do
    expect_no_offenses(<<~RUBY, "spec/support/shared_contexts.rb")
      FactoryBot.create(:user)
    RUBY
  end

  it "does not register an offense for a save mock in a model spec" do
    expect_no_offenses(<<~RUBY, "spec/models/user_spec.rb")
      allow(user).to receive(:save).and_return(true)
    RUBY
  end
end
