require "colorized_string"

class ColourLogFormatter < Lograge::Formatters::KeyValue
  FIELDS_COLOURS = {
    method: :red,
    path: :red,
    format: :red,
    controller: :green,
    action: :green,
    status: :yellow,
    duration: :magenta,
    view: :magenta,
    db: :magenta,
    session_id: :cyan,
    ip: :cyan,
    params: :green
  }.freeze

  def format(key, value)
    line = super(key, value)

    colour = FIELDS_COLOURS[key] || :white
    ColorizedString.new(line).public_send(colour)
  end
end
