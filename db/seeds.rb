
10.times do |i|
  Widget.create!(title: "#{i}", content: "Content #{i}")
end
