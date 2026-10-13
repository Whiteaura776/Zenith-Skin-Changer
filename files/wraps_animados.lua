-- ANIMATED WRAPS of Rivals (v6.15). The game animates each wrap with its own module (PlayerScripts.Modules.WrapGroupObjects.<name>)
-- that moves that wrap's textures every frame. Here is what each one does, rebuilt from its code (the game's code is not used
-- and nothing from the game is required). It is loaded from cielo_main.lua: it returns a function that receives WRAPANIM and adds
-- the animations to WRAPANIM.fn[<module name>] = function(e, t, dt):
--   e  = { copias = {the wrap's textures on the weapon}, partes = {parts with that wrap}, ... }  (grouped by name on first use)
--   t  = workspace:GetServerTimeNow(), dt = seconds since the previous pass of this wrap
-- NOT copied: the particles, beams and trails (ParticleEmitter/Beam/Trail) that some wraps carry.
return function(W)
    local fn = W.fn
    local clamp, sin, floor, pi = math.clamp, math.sin, math.floor, math.pi
    local PI2 = 6.283185307179586
    local DESFASE = 3.5342917352885173 -- phase offset of the two alternating layers (Aegis, Only Six, Polaris, Tidal)

    local function id(n) return "rbxassetid://" .. n end

    -- groups the textures by name and keeps each one's tile size (the animations that need it change it)
    local function ini(e)
        if e.g then return end
        e.g, e.su, e.sv = {}, {}, {}
        e.az = Random.new()
        for _, x in ipairs(e.copias) do
            local l = e.g[x.Name]
            if not l then
                l = {}
                e.g[x.Name] = l
            end
            table.insert(l, x)
            e.su[x], e.sv[x] = x.StudsPerTileU, x.StudsPerTileV
        end
    end
    local function de(e, nombre) return e.g[nombre] or {} end

    -- a list of images applied to the textures (preloaded so they do not appear in pieces)
    local function imagenes(lista)
        for i, n in ipairs(lista) do lista[i] = id(n) end
        task.spawn(function()
            pcall(function() game:GetService("ContentProvider"):PreloadAsync(lista) end)
        end)
        return lista
    end

    local function quadInOut(k) return k < 0.5 and 2 * k * k or 1 - (-2 * k + 2) ^ 2 / 2 end

    -- ------------------------------------------------------------------ Ice Queen
    local COPOS = imagenes({ 138393431257124, 107051054528784, 125054446055112, 110582063087757, 119507229017142,
        97696327350095, 108305398626234, 107586098443052, 102752148910886, 96190250840477, 83191963862467, 101078325262094 })
    fn["Ice Queen"] = function(e, t)
        ini(e)
        for _, x in ipairs(de(e, "TopArrows")) do x.OffsetStudsU = -((t * 2) % e.su[x]) end
        for _, x in ipairs(de(e, "BottomArrows")) do x.OffsetStudsU = (t * 2) % e.su[x] end
        local ahora = os.clock()
        if ahora >= (e.siguiente or 0) then
            e.siguiente = ahora + 0.03
            e.cuadro = ((e.cuadro or 1) % #COPOS) + 1
            for _, x in ipairs(de(e, "Snowflake")) do x.Texture = COPOS[e.cuadro] end
        end
    end

    -- ------------------------------------------------------------------ Soul Scourge
    fn["Soul Scourge"] = function(e, t)
        ini(e)
        local u = t / 4
        for _, x in ipairs(de(e, "Souls")) do
            x.OffsetStudsV = u % 0.6
            x.OffsetStudsU = sin(u * 10) / 14 + e.az:NextNumber(-0.01, 0.01)
        end
        for _, x in ipairs(de(e, "Clouds2")) do
            x.OffsetStudsU = u % 0.7
            x.OffsetStudsV = u % 0.5
        end
    end

    -- ------------------------------------------------------------------ Neon Lights
    fn["Neon Lights"] = function(e)
        ini(e)
        local v = (floor(tick() * 10) * 0.027) % 0.25
        if v ~= e.v then
            e.v = v
            for _, x in ipairs(e.copias) do x.OffsetStudsV = v end
        end
    end

    -- ------------------------------------------------------------------ Solar (the wire shakes)
    fn["Solar"] = function(e)
        ini(e)
        for _, x in ipairs(de(e, "Wireframe")) do
            x.OffsetStudsU = (math.random() - 0.5) * 0.01
            x.OffsetStudsV = (math.random() - 0.5) * 0.01
        end
    end

    -- ------------------------------------------------------------------ Speed (the stripes run in jolts)
    fn["Speed"] = function(e, t, dt)
        ini(e)
        e.shift = ((e.shift or 0) + dt * (0.25 + 0.75 * sin(tick() * 1.0) ^ 20)) % 0.2
        for _, x in ipairs(e.copias) do
            x.OffsetStudsU = e.shift * (x.Name == "Left" and 1 or -1)
        end
    end

    -- ------------------------------------------------------------------ Celestial
    fn["Celestial"] = function(e)
        ini(e)
        local tk = tick()
        for _, x in ipairs(e.copias) do
            local fase = (tk * 0.01 + (x.Name == "Big" and 0.5 or 0)) % 1
            x.Transparency = sin(pi * fase - pi / 2) ^ 20 * 0.75 + 0.25
            local tam = 0.05 + 1.075 * fase ^ 2
            x.StudsPerTileU, x.StudsPerTileV = tam, tam
        end
    end

    -- ------------------------------------------------------------------ Dark Matter (uses the Speed and Direction attributes)
    fn["Dark Matter"] = function(e)
        ini(e)
        if not e.mov then
            e.mov = {}
            for _, x in ipairs(e.copias) do
                local v, d = x:GetAttribute("Speed"), x:GetAttribute("Direction")
                if v and d then table.insert(e.mov, { x, v, d }) end
            end
        end
        local tk = tick()
        for _, m in ipairs(e.mov) do
            local x, v, d = m[1], m[2], m[3]
            x.OffsetStudsU = (tk * v * d.X) % e.su[x]
            x.OffsetStudsV = (tk * v * d.Y) % e.sv[x]
        end
    end

    -- ------------------------------------------------------------------ Rivalry (moves with the camera)
    fn["Rivalry"] = function(e, t)
        ini(e)
        local cam = workspace.CurrentCamera
        local pos = (cam.CFrame * cam.Focus).Position
        local u = t / 7
        local deParte = {}
        for _, x in ipairs(e.copias) do
            local p = x.Parent
            local d = deParte[p]
            if not d then
                d = p.Position - pos
                deParte[p] = d
            end
            local div = x.Name == "RibbonTexture2" and 800 or 1300
            x.OffsetStudsU = d.Z / div + (u % e.su[x])
            x.OffsetStudsV = d.Y / div + (u % e.sv[x])
        end
    end

    -- ------------------------------------------------------------------ Encroached (the glyphs run and sometimes shake)
    fn["Encroached"] = function(e, t, dt)
        ini(e)
        e.el = (e.el or 0) + dt / 5
        e.el2 = (e.el2 or 0) + dt
        if e.el2 >= 2 then
            e.el2 = 0
            e.golpe = os.clock() -- Value = 0.05 and drops to 0 in 0.75 s (Quint Out)
        end
        local val = 0
        if e.golpe then
            local p = (os.clock() - e.golpe) / 0.75
            if p >= 1 then e.golpe = nil else val = 0.05 * (1 - p) ^ 5 end
        end
        if val ~= e.val then
            e.val = val
            e.ju, e.jv = e.az:NextNumber(-val, val), e.az:NextNumber(-val, val)
        end
        local ju, jv, tr = e.ju or 0, e.jv or 0, 0.55 + val * 2
        for _, x in ipairs(de(e, "Glyphs1")) do
            x.OffsetStudsU = -(e.el % e.su[x]) + ju
            x.OffsetStudsV = -(e.el % e.sv[x]) + jv
            x.Transparency = tr
        end
        for _, x in ipairs(de(e, "Glyphs2")) do
            x.OffsetStudsU = (e.el % e.su[x]) + ju
            x.OffsetStudsV = (e.el % e.sv[x]) + jv
            x.Transparency = tr
        end
    end

    -- ------------------------------------------------------------------ Fracture
    fn["Fracture"] = function(e, t)
        ini(e)
        local base = sin(t * 1.5) / 7 + 0.75
        for _, x in ipairs(de(e, "Shatter")) do
            x.StudsPerTileU = base + 1.574 + e.az:NextNumber(-0.02, 0.02)
            x.StudsPerTileV = base + 1.574 + e.az:NextNumber(-0.02, 0.02)
        end
        for _, x in ipairs(de(e, "Shatter2")) do
            x.StudsPerTileU = base / 1.75 + 2.5 + e.az:NextNumber(-0.01, 0.01)
            x.StudsPerTileV = base / 1.75 + 2.5 + e.az:NextNumber(-0.01, 0.01)
        end
    end

    -- ------------------------------------------------------------------ Aegis
    fn["Aegis"] = function(e, t)
        ini(e)
        local u = t / 4
        local a1 = clamp(sin(u * 24) / 3 + 0.5, 0, 1)
        local a2 = clamp(sin((u + DESFASE) * 24) / 3 + 0.5, 0, 1)
        for _, x in ipairs(de(e, "Sparkles")) do
            x.OffsetStudsV = u % e.sv[x]
            x.Transparency = a1
        end
        for _, x in ipairs(de(e, "Sparkles2")) do
            x.OffsetStudsV = u % e.sv[x]
            x.Transparency = a2
        end
    end

    -- ------------------------------------------------------------------ Only Six
    fn["Only Six"] = function(e, t)
        ini(e)
        local u = t / 8
        local a1 = clamp(sin(u * 24) / 2 + 0.25, 0, 1)
        local a2 = clamp(sin((u + DESFASE) * 24) / 2 + 0.25, 0, 1)
        local tam = (sin(u) + 4) / 2
        for _, nombre in ipairs({ "RedStars", "BlueStars2" }) do
            for _, x in ipairs(de(e, nombre)) do
                x.StudsPerTileU, x.StudsPerTileV, x.Transparency = tam, tam, a1
            end
        end
        for _, nombre in ipairs({ "BlueStars", "RedStars2" }) do
            for _, x in ipairs(de(e, nombre)) do
                x.StudsPerTileU, x.StudsPerTileV, x.Transparency = tam, tam, a2
            end
        end
    end

    -- ------------------------------------------------------------------ Scribble (two scribbles that alternate every 0.15 s)
    local GARABATOS = imagenes({ 112448109089773, 85215887790060 })
    fn["Scribble"] = function(e, t)
        ini(e)
        if t < (e.sig or 0) then return end
        e.sig = t + 0.15
        e.i = (e.i or 0) + 1
        local a = (e.i % 2) + 1
        for _, x in ipairs(de(e, "Scribbles")) do x.Texture = GARABATOS[a] end
        for _, x in ipairs(de(e, "Scribbles2")) do x.Texture = GARABATOS[3 - a] end
    end

    -- ------------------------------------------------------------------ Blizzard
    fn["Blizzard"] = function(e, t)
        ini(e)
        for _, x in ipairs(de(e, "Clouds1")) do
            x.OffsetStudsU = e.su[x] - ((t / 2) % e.su[x])
            x.OffsetStudsV = e.sv[x] - (t % e.sv[x])
        end
        for _, x in ipairs(de(e, "Clouds2")) do
            x.OffsetStudsU = (t / 2) % e.su[x]
            x.OffsetStudsV = e.sv[x] - (t % e.sv[x])
        end
        for _, x in ipairs(de(e, "Snow1")) do
            x.OffsetStudsU = e.su[x] - (t % e.su[x])
            x.OffsetStudsV = e.sv[x] - ((t / 2) % e.sv[x])
        end
        for _, x in ipairs(de(e, "Snow2")) do
            x.OffsetStudsU = t % e.su[x]
            x.OffsetStudsV = e.sv[x] - ((t / 2) % e.sv[x])
        end
    end

    -- ------------------------------------------------------------------ Festive Lights (red, yellow and green, one per second)
    local LUCES = { { "SolidRed", "RedLightsInner" }, { "SolidYellow", "YellowLightsInner" }, { "SolidGreen", "GreenLightsInner" } }
    fn["Festive Lights"] = function(e)
        ini(e)
        local idx = floor(tick() * 1) % 3 + 1
        if idx == e.ult then return end
        e.ult = idx
        for k, nombres in ipairs(LUCES) do
            local tr = (k == idx) and 0 or 1
            for _, nombre in ipairs(nombres) do
                for _, x in ipairs(de(e, nombre)) do x.Transparency = tr end
            end
        end
    end

    -- ------------------------------------------------------------------ Borealis
    fn["Borealis"] = function(e, t)
        ini(e)
        local u = t / 4
        local v = sin(u * 4) / 14
        if not e.cara then
            e.cara = {}
            for _, x in ipairs(de(e, "Gradient")) do
                e.cara[x] = (x.Face == Enum.NormalId.Top or x.Face == Enum.NormalId.Front)
            end
        end
        for _, x in ipairs(de(e, "Gradient")) do
            local o = (u / 2.5) % e.su[x]
            x.OffsetStudsU = e.cara[x] and -o or o
            x.OffsetStudsV = v
        end
    end

    -- ------------------------------------------------------------------ Polaris
    fn["Polaris"] = function(e, t)
        ini(e)
        local u = t / 4
        local a1 = clamp(sin(u * 12) / 3 + 0.5, 0, 1)
        for _, nombre in ipairs({ "Fire1", "Fire2" }) do
            for _, x in ipairs(de(e, nombre)) do x.Transparency = a1 end
        end
        local tb = sin(u * 6) / 10 + 0.8
        for _, x in ipairs(de(e, "Beam")) do pcall(function() x.Transparency = tb end) end
        for _, x in ipairs(de(e, "Sparks1")) do
            x.OffsetStudsU = ((u / 4) % e.su[x]) + sin(u * 9) / 64
            x.OffsetStudsV = (u / 2) % e.sv[x]
            x.Transparency = sin(u * 8) / 10 + 0.2
        end
    end

    -- ------------------------------------------------------------------ The Heights (the ring of fire, 38 frames in reverse)
    local FUEGO = imagenes({ 2590541, 83032711602009, 128727548904352, 90166684921447, 140239100555084, 97272253453870,
        126082024890331, 131249583090004, 130283158493590, 114556019900394, 112466666772902, 117101826648137, 114538468748606,
        139873735674722, 103775503564962, 98373420251654, 79425698371704, 87166826689312, 90076189567688, 139561695601892,
        140445824066751, 90343553347218, 80578694078644, 75411897165689, 120909749571199, 112084468503688, 126283045144965,
        129853781030059, 136743858401776, 119486130155706, 132663054692921, 133945106822765, 70983245593146, 115582632329247,
        129297227277092, 87912065660686, 81705944196717, 78878769229079 })
    fn["The Heights"] = function(e, t)
        ini(e)
        if t < (e.ultimo or 0) + (e.intervalo or 0) then return end
        e.ultimo, e.intervalo = t, 0.04
        local n = #FUEGO
        local u1, u2 = n / 2, n - 8
        local f = (e.f or 1) - 1
        if f < 1 then f = n end
        e.f = f
        if not (f == n or f == 1) and not (u1 <= f) and f < u2 then
            local r = ((f - u1) / u1) * 10 + (1 - f / u2)
            e.intervalo = 0.04 / (r + 1)
        end
        local tr = clamp(((f - u1) / u1) * 10 + (1 - f / u2), 0, 1)
        for _, x in ipairs(de(e, "FireRing")) do
            x.Texture = FUEGO[f]
            x.Transparency = tr
        end
        for _, x in ipairs(de(e, "FireRingGlow")) do x.Transparency = math.max(tr, 0.5) end
    end

    -- ------------------------------------------------------------------ Heartfelt
    fn["Heartfelt"] = function(e, t)
        ini(e)
        local u = t / 4
        for _, x in ipairs(de(e, "Hearts")) do
            x.OffsetStudsV = u % e.sv[x]
            x.OffsetStudsU = (u / 3) % e.su[x]
        end
        for _, x in ipairs(de(e, "Hearts2")) do
            x.OffsetStudsV = (u / 2.5) % e.sv[x]
            x.OffsetStudsU = (u / 7) % e.su[x]
        end
    end

    -- ------------------------------------------------------------------ Chromatic (rainbow)
    local CARA_EJE = { [Enum.NormalId.Top] = "Y", [Enum.NormalId.Bottom] = "Y", [Enum.NormalId.Left] = "X",
        [Enum.NormalId.Right] = "X", [Enum.NormalId.Front] = "Z", [Enum.NormalId.Back] = "Z" }
    fn["Chromatic"] = function(e, t)
        ini(e)
        local u = t / 2
        local h = u / 4
        for _, x in ipairs(de(e, "Gradient1")) do x.OffsetStudsU = u % e.su[x] end
        for _, x in ipairs(de(e, "Gradient2")) do x.OffsetStudsU = -(u % e.su[x]) end
        if not e.fase then
            -- each face starts at a different hue depending on the size of the part in that direction
            e.fase = {}
            for _, nombre in ipairs({ "SolidBack", "SolidFront" }) do
                for _, x in ipairs(de(e, nombre)) do
                    local p = x.Parent
                    e.fase[x] = (p and p.Size[CARA_EJE[x.Face] or "X"] or 0) / 4 / 2
                end
            end
        end
        for _, nombre in ipairs({ "SolidBack", "SolidFront" }) do
            for _, x in ipairs(de(e, nombre)) do
                local c = Color3.fromHSV((h + e.fase[x]) % 1, 1, 1)
                x.Color3 = Color3.fromRGB(c.R * 255 * 1.5686274509803921, c.G * 255 * 1.5686274509803921, c.B * 255 * 1.5686274509803921)
            end
        end
    end

    -- ------------------------------------------------------------------ Orichalcum
    fn["Orichalcum"] = function(e, t)
        ini(e)
        for _, x in ipairs(de(e, "WeirdPaintOverlay")) do
            x.OffsetStudsU = (t / 15) % e.su[x]
            x.OffsetStudsV = (t / 15) % e.sv[x]
            x.Transparency = sin(t * 1.25) / 7 + 0.25
        end
        local tam = ((sin(t / 2.5) / 1.2 + 2) / 6) + 2
        for _, x in ipairs(de(e, "WeirdPaintOverlay2")) do
            x.StudsPerTileU, x.StudsPerTileV = tam, tam
        end
    end

    -- ------------------------------------------------------------------ Crime Scene (police tape and red and blue lights)
    fn["Crime Scene"] = function(e, t)
        ini(e)
        local u = t / 5
        for _, x in ipairs(de(e, "PoliceTape1")) do
            x.OffsetStudsU = -(u % e.su[x])
            x.OffsetStudsV = u % e.sv[x]
        end
        for _, x in ipairs(de(e, "PoliceTape2")) do
            x.OffsetStudsU = (u % e.su[x]) + 0.5
            x.OffsetStudsV = u % e.sv[x]
        end
        -- the lights go from their color to the other and back (1 s each leg, Quad InOut, nonstop)
        if not e.col0 then
            e.col0 = {}
            for _, nombre in ipairs({ "GlowRed", "GlowBlue" }) do
                for _, x in ipairs(de(e, nombre)) do e.col0[x] = x.Color3 end
            end
            e.inicio = t
        end
        local p = (t - e.inicio) % 2
        local k = quadInOut(p < 1 and p or 2 - p)
        local rojo = Color3.fromRGB(50, 62, 225)
        local azul = Color3.fromRGB(225, 47, 47)
        for _, x in ipairs(de(e, "GlowRed")) do x.Color3 = e.col0[x]:Lerp(rojo, k) end
        for _, x in ipairs(de(e, "GlowBlue")) do x.Color3 = e.col0[x]:Lerp(azul, k) end
    end

    -- ------------------------------------------------------------------ TV Error and TV Static (the TV with no signal)
    local TELE = imagenes({ 76762297951095, 104650396345178, 128067608046117 })
    local function tele(e, t, dt, conOscuro)
        ini(e)
        e.cuenta = (e.cuenta or 0) + dt
        e.cuadro = e.cuadro or 1
        if e.cuenta >= 0.04 then
            e.cuenta = 0
            e.cuadro = (e.cuadro + 1 > #TELE) and 1 or e.cuadro + 1
        end
        local tr = sin(t * 10) / 10 + 0.1
        local imagen = TELE[e.cuadro]
        for _, x in ipairs(de(e, "Static")) do
            x.OffsetStudsU = e.az:NextInteger(-1, 1) / 250
            x.OffsetStudsV = e.az:NextInteger(-1, 1) / 250
            x.Texture = imagen
            x.Transparency = tr
        end
        if conOscuro then
            for _, x in ipairs(de(e, "StaticDark")) do
                x.OffsetStudsU = e.az:NextInteger(-1, 1) / 250
                x.OffsetStudsV = e.az:NextInteger(-1, 1) / 250
                x.Texture = imagen
                x.Transparency = tr / 1.25 + 0.35
            end
        end
    end
    fn["TV Error"] = function(e, t, dt) tele(e, t, dt, false) end
    fn["TV Static"] = function(e, t, dt) tele(e, t, dt, true) end

    -- ------------------------------------------------------------------ Tidal (waves, foam, shadows and caustics)
    local function mover(e, x, a, b, c, t)
        local u = t / 1.5
        x.OffsetStudsU = (-(u / 10 - a)) % e.su[x]
        x.OffsetStudsV = ((sin(u - b) / 6 + 0.2) % e.sv[x]) + (c - 0.1)
    end
    fn["Tidal"] = function(e, t)
        ini(e)
        local u = t / 7.5
        local a1 = clamp(sin(u * 24) / 3 + 0.5, 0, 1)
        local a2 = clamp(sin((u + DESFASE) * 24) / 3 + 0.5, 0, 1)
        for _, nombre in ipairs({ "Waves", "WavesCaustics" }) do
            for _, x in ipairs(de(e, nombre)) do mover(e, x, 0, 0, 0, t) end
        end
        for _, x in ipairs(de(e, "WavesFoam")) do mover(e, x, 0, 0, 0.05, t) end
        for _, x in ipairs(de(e, "WavesShade1")) do mover(e, x, 0.01, 0.6, 0, t) end
        for _, x in ipairs(de(e, "WavesShade2")) do mover(e, x, 0.035, 0.9, 0, t) end
        for _, x in ipairs(de(e, "Caustics")) do x.Transparency = a1 end
        for _, x in ipairs(de(e, "Caustics2")) do x.Transparency = a2 end
    end

    -- ------------------------------------------------------------------ Paparazzi (random camera flashes)
    -- every 0.3-0.5 s a group of flashes (different from the previous one) changes place and flashes 1 to 3 times: it appears in 0.05 s and
    -- fades out in 0.25-0.3 s (Quart Out); the big background flashes separately (0.85 -> 1)
    local function flashes(e, ahora)
        local act = e.activos
        for i = #act, 1, -1 do
            local f = act[i]
            local u = ahora - f.t0
            local tr
            if f.fondo then
                local k = u / (f.dur + 0.5)
                tr = k < 1 and 0.85 + 0.15 * (1 - (1 - k) ^ 4) or nil
            else
                local P = 0.05 + f.dur / 1.5
                local rep = math.min(floor(u / P), f.n - 1)
                local r = u - rep * P
                if r < 0.05 then
                    tr = 1 - (r / 0.05) ^ 2 -- appears (Quad In)
                else
                    local k = (r - 0.05) / f.dur
                    tr = k < 1 and 1 - (1 - k) ^ 4 or nil -- fades out (Quart Out)
                end
            end
            if tr then
                f.x.Transparency = tr
            else
                f.x.Transparency = 1
                table.remove(act, i)
            end
        end
    end
    fn["Paparazzi"] = function(e, t, dt)
        ini(e)
        local ahora = os.clock()
        if not e.activos then
            e.activos, e.arranque, e.sig = {}, 0, 0.4
            for k = 1, 4 do
                for _, x in ipairs(de(e, "Flashes" .. k)) do x.Transparency = 1 end
            end
        end
        e.arranque = e.arranque + dt
        if e.arranque >= e.sig then
            e.sig = e.arranque + e.az:NextNumber(0.3, 0.5)
            local opciones = {}
            for k = 1, 4 do if k ~= e.ultimoGrupo then table.insert(opciones, k) end end
            e.ultimoGrupo = opciones[e.az:NextInteger(1, #opciones)]
            local dur = e.az:NextNumber(0.25, 0.3)
            local n = e.az:NextInteger(1, 3)
            for _, x in ipairs(de(e, "Flashes" .. e.ultimoGrupo)) do
                x.OffsetStudsU = e.az:NextNumber(0, 5)
                x.OffsetStudsV = e.az:NextNumber(0, 5)
                table.insert(e.activos, { x = x, t0 = ahora, dur = dur, n = n })
            end
            for _, x in ipairs(de(e, "FlashesBackground")) do
                x.Transparency = 0.85
                table.insert(e.activos, { x = x, t0 = ahora, dur = dur, n = 1, fondo = true })
            end
        end
        flashes(e, ahora)
    end

    -- ------------------------------------------------------------------ Dutchman (green lightning)
    fn["Dutchman"] = function(e, t, dt)
        ini(e)
        e.started = (e.started or 0) + dt
        if not e.cara then
            e.cara = {}
            for _, nombre in ipairs({ "Gradient", "Gradient2" }) do
                for _, x in ipairs(de(e, nombre)) do
                    e.cara[x] = (x.Face == Enum.NormalId.Top or x.Face == Enum.NormalId.Front)
                end
            end
            e.piezas = {}
            for _, p in ipairs(e.partes or {}) do
                if p:FindFirstChild("Lightning") and p:FindFirstChild("Gradient2") then table.insert(e.piezas, p) end
            end
        end
        local s = e.started
        for _, x in ipairs(de(e, "Gradient")) do
            local o = (s / 2.25) % e.su[x]
            x.OffsetStudsU = e.cara[x] and -o or o
        end
        for _, x in ipairs(de(e, "Gradient2")) do
            local o = (-(s / 2.25)) % e.su[x]
            x.OffsetStudsU = e.cara[x] and -o or o
        end
        local ahora = os.clock()
        if s >= (e.siguiente or 0) then
            e.siguiente = s + e.az:NextNumber(0.6, 1.7)
            e.golpe = ahora
            for _, x in ipairs(de(e, "Lightning")) do x.Transparency = 0.01 end
            for _, p in ipairs(e.piezas) do p.Color = Color3.fromRGB(134, 255, 180) end
        end
        if e.golpe then
            local k = clamp((ahora - e.golpe) / 0.5, 0, 1)
            local suave = 1 - (1 - k) ^ 2 -- Quad Out
            for _, x in ipairs(de(e, "Lightning")) do x.Transparency = 0.01 + (1 - 0.01) * suave end
            local c = Color3.fromRGB(134, 255, 180):Lerp(Color3.fromRGB(89, 171, 123), suave)
            for _, p in ipairs(e.piezas) do p.Color = c end
            if k >= 1 then e.golpe = nil end
        end
    end

    -- ------------------------------------------------------------------ Pearlescent (pearly: the color changes depending on where you look)
    local NACAR_S = { 0.086, 0.156, 0.128 }
    local NACAR_V = { 1, 1, 0.639 }
    local function normal(a) return math.abs(((a % PI2) / PI2) * 2 - 1) end
    fn["Pearlescent"] = function(e)
        local cf = workspace.CurrentCamera.CFrame
        local rx, ry, rz = cf:ToEulerAnglesXYZ()
        local desp = (cf.Position + Vector3.new(normal(rx), normal(ry), normal(rz)) * 32).Magnitude / 128
        local h = desp % 1
        for _, p in ipairs(e.partes or {}) do
            local g = p:GetAttribute("WrapGroup") or 1
            p.Color = Color3.fromHSV(h, NACAR_S[g] or NACAR_S[1], NACAR_V[g] or NACAR_V[1])
        end
    end

    -- ------------------------------------------------------------------ Pixel Blight and Fish Scales: they only change the part's color, once
    -- (applied when the material is set: W.colorUnico[name](color) returns the new color)
    W.colorUnico = {
        ["Pixel Blight"] = function(c)
            local h, s, v = c:ToHSV()
            local umbral = (0.5 < s) and 0.1 or 0.35
            if v < umbral then return c end
            return Color3.fromHSV(h, s, math.max(0.75, v))
        end,
        ["Fish Scales"] = function(c)
            local _, s, v = c:ToHSV()
            local h = Random.new(floor(os.time() / 86400)):NextNumber(0, 0.92) -- the same hue all day
            return Color3.fromHSV(h, s, v)
        end,
    }
end
