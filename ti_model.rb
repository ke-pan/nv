class Wire
  attr_reader :value
  def initialize(value, toggle_rate)
    @value = value % 2
    @toggle_rate = toggle_rate
  end

  def toggle?
    @last_value != @value
  end

  def toggle
    @value = (@value + 1) % 2
  end

  def tick
    @last_value = @value
    if Random.rand < @toggle_rate
      toggle
    else
      @value
    end
  end

  def to_s
    @value.to_s
  end
end

class Bus
  attr_reader :width, :bus, :toggle_rate
  def initialize(bus_or_width, toggle_rate=0.5)
    if bus_or_width.is_a? Bus
      @width = bus_or_width.width
      @toggle_rate = bus_or_width.toggle_rate
      @bus = Array.new(@width) {|i| Wire.new(bus_or_width[i], @toggle_rate)}
    else
      @width = bus_or_width
      @toggle_rate = toggle_rate
      @bus = Array.new(@width) { Wire.new(0, @toggle_rate) }
    end
  end

  def [](i)
    @bus[i].value
  end

  def tick
    @bus.each { |wire| wire.tick }
    self
  end

  def toggle?(threshold)
    toggle_percent > threshold.to_f
  end

  def toggle
    @bus.each { |wire| wire.toggle }
  end

  def toggle_wires_count
    @bus.count { |wire| wire.toggle? }
  end

  def toggle_percent
    toggle_wires_count / @width.to_f
  end

  def to_s
    @bus.reduce('') { |bus, wire| bus + wire.value.to_s }
  end

  def distance(bus)
    return -1 if width != bus.width
    width.times.map {|i| self[i] != bus[i] ? 1 : 0 }.inject(&:+)
  end
end

class TI #Toggle Inverter
  def initialize(bus, threshold=0.5)
    @bus = Bus.new(bus)
    @origin_bus = bus
    @threshold = threshold
    @value = 0
  end

  def tick
    @last_value = @value
    @last_bus = @bus
    @bus = Bus.new(@origin_bus)
    if bus_toggle?
      @bus.toggle
      @value = 1
    else
      @value = 0
    end
  end

  def bus_toggle?
    # puts @bus, 'bus'
    # puts @origin_bus, 'origin_bus'
    # puts @bus.distance(@origin_bus)
    @last_bus.distance(@bus) / @bus.width.to_f > @threshold
  end

  def toggle?
    @last_value != @value
  end

  def toggle_wires_count
    bus_toggle_wires_count + ti_toggle_count
  end

  def ti_toggle_count
    toggle? ? 1 : 0
  end

  def bus_toggle_wires_count
    @last_bus.distance(@bus)
  end

  def toggle_percent
    toggle_wires_count.to_f / (@bus.width + 1)
  end

  def to_s
    "#{@bus}#{@value}"
  end

end

class Bus_with_TI
  def initialize(bus, ti=nil)
    @ti = ti ||= TI.new(bus)
    @bus = bus
  end

  def tick
    @bus.tick
    @ti.tick
    # puts @bus
    # puts @ti
    # puts bus_toggle_wires_count_with_ti
    # puts '---'
  end

  def toggle_wires_count_with_ti
    @ti.toggle_wires_count
  end

  def ti_toggle_count
    @ti.ti_toggle_count
  end

  def bus_toggle_wires_count_with_ti
    @ti.bus_toggle_wires_count
  end

  def toggle_percent_with_it
    @ti.toggle_percent
  end

  def toggle_wires_count_without_ti
    @bus.toggle_wires_count
  end

  def toggle_percent_without_it
    @bus.toggle_percent
  end

end

width = 64
cycle_number = 10000
toggle_rate = 0.5

bus = Bus.new(width, toggle_rate)
bus_with_ti = Bus_with_TI.new(bus)

toggle_sum_with_ti = 0
bus_toggle_sum_with_ti = 0
ti_toggle_sum_with_ti = 0
bus_toggle_sum_without_ti = 0

cycle_number.times do
  bus_with_ti.tick
  toggle_sum_with_ti += bus_with_ti.toggle_wires_count_with_ti
  bus_toggle_sum_with_ti += bus_with_ti.bus_toggle_wires_count_with_ti
  ti_toggle_sum_with_ti += bus_with_ti.ti_toggle_count
  bus_toggle_sum_without_ti += bus_with_ti.toggle_wires_count_without_ti
end

puts toggle_sum_with_ti
puts toggle_sum_with_ti / (width+1)*cycle_number.to_f
puts bus_toggle_sum_with_ti
puts bus_toggle_sum_with_ti / width*cycle_number.to_f
puts ti_toggle_sum_with_ti
puts bus_toggle_sum_without_ti
puts bus_toggle_sum_without_ti / width*cycle_number.to_f
