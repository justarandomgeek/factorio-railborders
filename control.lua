
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]

  player.insert{name="iron-plate", count=200}
  player.insert{name="copper-plate", count=200}
  player.insert{name="shotgun", count=1}
  player.insert{name="shotgun-shell", count=50}

  player.insert{name="modular-armor", count=1}

  local grid = player.get_inventory(defines.inventory.player_armor)[1].grid

  grid.put{name="personal-roboport-equipment", position = {0,0} }
  grid.put{name="personal-roboport-equipment", position = {3,0} }
  grid.put{name="battery-equipment", position = {2,0} }

  for x = 0,4 do
    for y = 2,4 do
      grid.put{name="solar-panel-equipment", position={x,y}}
    end
  end

  player.insert{name="construction-robot", count=20}

  player.insert{name="locomotive", count=1}
  player.insert{name="nuclear-fuel", count=1}
end)

script.on_init(function()
  local surface = game.surfaces['nauvis']

  local mgs = surface.map_gen_settings

  -- if height wasn't set, just set it... 128 is the default for Ribbon World preset
  mgs.height = mgs.height or 128

  -- ensure height has appropriate margin alignment - needs to be 12 tiles beyond a chunk boundary
  mgs.height = mgs.height + (24-(mgs.height % 32))

  surface.map_gen_settings = mgs

end)

script.on_configuration_changed(function(event)

end)


local top={
  [0] = "concrete",
  [1] = "hazard-concrete-right",
  [2] = "hazard-concrete-left",
  [3] = "concrete"
}

local bottom={
  [0] = "concrete",
  [1] = "hazard-concrete-left",
  [2] = "hazard-concrete-right",
  [3] = "concrete"
}

function generate_poles(upperlower,surface,area)
  local height = surface.map_gen_settings.height/2
  local poles = {}
  for key,pos in pairs({
    {area.left_top.x,   upperlower*(height-6)},
    {area.left_top.x+16,upperlower*(height-6)},
    {area.left_top.x+32,upperlower*(height-6)},
  }) do
    local pole = surface.find_entity("big-electric-pole",pos)
    if not pole then
      pole = surface.create_entity{name="big-electric-pole", force=game.forces.neutral, position=pos}
    end

    pole.minable = false
    pole.destructible = false

    poles[key] = pole
  end

  poles[2].connect_neighbour{target_entity=poles[1], wire=defines.wire_type.red}
  poles[2].connect_neighbour{target_entity=poles[1], wire=defines.wire_type.green}
  poles[2].connect_neighbour{target_entity=poles[3], wire=defines.wire_type.red}
  poles[2].connect_neighbour{target_entity=poles[3], wire=defines.wire_type.green}
end

script.on_event(defines.events.on_chunk_generated, function(event)
  local surface = event.surface
  if surface.name == "nauvis" then
    local height = surface.map_gen_settings.height/2

    if event.area.left_top.y < -height then
      -- upper stripe
      for _,ent in pairs(surface.find_entities(event.area)) do
        if ent.valid and ent.name ~= "big-electric-pole" then
          ent.destroy()
        end
      end

      local tiles = {}
      for x=event.area.left_top.x,event.area.right_bottom.x do
        for y=-(height-1),event.area.right_bottom.y-1 do
          tiles[#tiles+1] = {name=top[x%4] , position = {x,y}}
        end
        tiles[#tiles+1] = {name='water' , position = {x,-height}}
      end
      surface.set_tiles(tiles)

      for x=event.area.left_top.x+1,event.area.right_bottom.x-1,2 do
        local ent = surface.create_entity{name="straight-rail", force=game.forces.neutral, direction=2, position={x,-height+3}}
        ent.minable = false
        ent.destructible = false

        ent = surface.create_entity{name="straight-rail", force=game.forces.neutral, direction=2, position={x,-height+9}}
        ent.minable = false
        ent.destructible = false
      end

      surface.create_entity{name="rail-signal", force=game.forces.player, direction=2, position={event.area.left_top.x+0.5,-height+1.5}}
      surface.create_entity{name="rail-signal", force=game.forces.player, direction=2, position={event.area.left_top.x+0.5,-height+7.5}}

      generate_poles(-1,surface,event.area)
    elseif event.area.right_bottom.y > height then
      -- lower stripe
      for _,ent in pairs(surface.find_entities(event.area)) do
        if ent.valid and ent.name ~= "big-electric-pole" then
          ent.destroy()
        end
      end

      local tiles = {}
      for x=event.area.left_top.x,event.area.right_bottom.x do
        for y=event.area.left_top.y,height-2 do
          tiles[#tiles+1] = {name=bottom[x%4] , position = {x,y}}
        end
        tiles[#tiles+1] = {name='water' , position = {x,height-1}}
      end
      surface.set_tiles(tiles)

      for x=event.area.left_top.x+1,event.area.right_bottom.x-1,2 do
        local ent = surface.create_entity{name="straight-rail", force=game.forces.neutral, direction=2, position={x,height-3}}
        ent.minable = false
        ent.destructible = false

        ent = surface.create_entity{name="straight-rail", force=game.forces.neutral, direction=2, position={x,height-9}}
        ent.minable = false
        ent.destructible = false
      end

      surface.create_entity{name="rail-signal", force=game.forces.player, direction=6, position={event.area.right_bottom.x-0.5,height-1.5}}
      surface.create_entity{name="rail-signal", force=game.forces.player, direction=6, position={event.area.right_bottom.x-0.5,height-7.5}}

      generate_poles(1,surface,event.area)
    end
  end
end)
