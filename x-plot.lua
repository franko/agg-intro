function example2()
  local w = window('h..')
  local p1, p2 = plot(), plot()
  local ln = path(0, 0)
  ln:line_to(20, 15)
  ln:line_to(28, 32)
  ln:line_to(10, 20)
  ln:line_to( 5, 40)
  ln:close()

  local box = rect(-5, 0, 35, 40)

  p1:addline(box, 'darkgray')
  p2:addline(box, 'darkgray')
  p1:add(ln)
  p2:add(ln, 'red', {}, {{'stroke', join='round'}})
  p1:limits(-5, 0, 35, 40)
  p2:limits(-5, 0, 35, 40)
  p1.units = false
  p2.units = false

  w:attach(p1, 1)
  w:attach(p2, 2)
  return p1, p2
end

