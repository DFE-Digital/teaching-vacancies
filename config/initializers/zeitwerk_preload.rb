# TODO: Active Record needs to have STI hierarchies fully loaded in order to generate
# correct SQL. The new autoloader (Zeitwerk) doesn't do this, so we need to manually
# make it preload all STI leaves on boot and reload. We may move away from STI to
# delegated types in the future, which won't require this workaround so we'll be able
# to delete this.

Rails.autoloaders.main.on_setup do
  [School, SchoolGroup]
end
