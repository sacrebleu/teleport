module Stats
  class Status
    attr_reader :endpoint, :metrics, :time


    def initialize(endpoint, metrics)
      @endpoint = endpoint
      @time = Time.now

      @metrics = parse(metrics)
    end

    # parses the prometheus metric output from a whatsapp cluster
    def parse(metrics)
      # lines starting with a # are comments
      lines = metrics.split /\n/
      lines.reject! { |e| e.strip.blank? }
      lines.reject! { |e| e.strip.starts_with?('#')}
      lines.map! { |l| StatusRow.new(l.split) }
      lines
    end

  end

  class StatusRow
    attr_reader :metric, :counter, :labels

    def initialize(args)

      @metric, label_string = args[0].split(/{/)
      @counter = args[1]

      label_string.gsub!("\"", "")
      label_string.gsub!("}", "")
      @labels = Hash[label_string.split(",").map {|v| v.split(/=/) }]
    end

    def to_partial_path
      'row'
    end
  end
end
