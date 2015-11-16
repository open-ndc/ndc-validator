# Rakefile

namespace :db do
  require "sequel"
  namespace :migrate do
    Sequel.extension :migration
    DB = Sequel.connect(ENV["DATABASE_URL"] || "sqlite://development.db")

    desc "Perform migration reset (full erase and migration up)"
    task :reset do
      Sequel::Migrator.run(DB, "migrations", :target => 0)
      Rake::Task['db:migrate:version'].execute
      Sequel::Migrator.run(DB, "migrations")
      Rake::Task['db:migrate:version'].execute
    end

    desc "Perform migration up/down to VERSION"
    task :to do
      version = ENV['VERSION'].to_i
      raise "No VERSION was provided" if version.nil?
      Sequel::Migrator.run(DB, "migrations", :target => version)
      puts "<= sq:migrate:to version=[#{version}] executed"
    end

    desc "Perform migration up to latest migration available"
    task :up do
      Sequel::Migrator.run(DB, "migrations")
      puts "<= sq:migrate:up executed"
    end

    desc "Perform migration down (erase all data)"
    task :down do
      Sequel::Migrator.run(DB, "migrations", :target => 0)
      puts "<= sq:migrate:down executed"
    end

    desc "Prints current schema version"
    task :version do
      version = if DB.tables.include?(:schema_info)
        DB[:schema_info].first[:version]
      end || 0

      puts "Schema Version: #{version}"
    end

  end
end
