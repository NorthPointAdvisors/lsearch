require 'date'

class LogFile

  attr_reader :path

  LOG_GLOB = "*log"

  class << self

    attr_writer :root, :glob, :date_rx

    def root
      @root || "/var/log/apps"
    end

    def glob
      @glob || "**/*log"
    end

    def date_rx
      @date_rx || /^(\d{4})-(\d{2})-(\d{2})/
    end

    def all(log_dir = nil)
      Dir.glob("#{log_dir || root}/#{glob}").collect do |path|
        new File.expand_path(path)
      end.sort_by { |x| x.name }
    end

    def find(app_name = nil, date = nil)
      found = all
      found.reject! { |x| x.app_name != app_name } if app_name
      found.reject! { |x| x.date_str != date.to_s } if date
      found
    end

    def first(app_name = nil, date = nil)
      find(app_name, date).first
    end

    def app_names
      all.map { |x| x.app_name }.uniq.sort
    end

    def has_app?(app_name)
      app_names.include? app_name.to_s
    end

    def dates
      all.map { |x| x.date_str }.uniq.sort
    end

  end

  def initialize(path)
    @path = path
  end

  alias_method :full_name, :path

  def parts
    path.split("/")
  end

  def app_name
    parts[-2]
  end

  def size
    File.size path
  end

  def date
    @date ||= parts.last =~ self.class.date_rx ? Date.new($1.to_i, $2.to_i, $3.to_i) : nil
  end

  def date_str
    date ? date.to_s : 'missing'
  end

  def name
    "#{app_name} #{date_str}"
  end

  def grep(options = { })
    offset  = (options[:offset] || 0).to_i
    limit   = (options[:limit] || 100).to_i
    filters = options[:filters] || { }

    File.open(@path, 'r') do |file|
      fsize = file.stat.size

      if offset.abs > fsize
        offset = offset < 0 ? 0 : file.stat.size
      end

      if offset < 0
        file.seek offset, IO::SEEK_END
        file.readline
      else
        file.seek offset
      end

      lines = []
      until file.eof? || lines.size == limit do
        line = file.readline.chop
        hash = LineProcessor.new(line).process
        if hash
          if LineFilter.new(hash, filters).ok?
            lines << hash if hash
          end
        end
      end
      offset = file.pos

      {
        :path     => @path,
        :app_name => app_name,
        :date_str => date_str,
        :offset   => offset,
        :limit    => limit,
        :size     => fsize,
        :count    => lines.size,
        :lines    => lines.compact,
      }
    end
  end

end

