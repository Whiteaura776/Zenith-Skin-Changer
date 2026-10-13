--[[
    CIELO ROBLOX - todo en una sola ventana (para Xeno)

    CIELO:   pone tu foto como cielo. Las fotos se agregan con la app "Cielo Roblox"
             del PC (arrastrando la foto o con clic para abrirla).
    COLORES: pinta los bloques del mapa del color que elijas en la rueda.
    SKINS y WRAPS (solo en Rivals): cualquier skin o wrap en tu arma, con sus sonidos,
             sus animaciones y su imagen en la barra de armas. Cada una con vista previa y
             su propia opacidad (en 0% el arma no se ve).
    DAÑO:    encima de la mira, una barrita que se llena con cada golpe hasta eliminar
             al que le pegas, con la vida que le queda. Se configura en la página DAÑO.
    FPS:     contador de FPS y botones para aligerar el juego (sombras, efectos de luz,
             terreno, luces del mapa): como bajar los gráficos.
    Todo es local: solo lo ves tú; los demás siguen viendo el juego normal.

    Tecla + (o -) = abrir / achicar la ventana (achicada queda un iconito del cielo)
    F8 = cielo on/off     F6 = colores on/off
    La ventana se mueve desde la cabecera y cambia de tamaño desde la esquina de abajo.
    Abierta, suelta el mouse (para poder usarla); achicada se juega normal.
    La × la esconde entera: todo sigue puesto. Si lo ejecutas otra vez, reemplaza al anterior.
    La app pone autoexec.lua en la carpeta autoexec de Xeno: al entrar a Rivals se ejecuta
    solo y empieza achicada (el iconito).
]]

-- versión: sube en cada cambio (la lista está en CAMBIOS.txt)
local VERSION = "v7.02"

-- (v6.97) PERFIL: con que forma se arma este script. "completo" = el del usuario (todo); "sky" = ZENITH SKY CHANGER (solo CIELO y COLORES) y "skins" = ZENITH SKIN CHANGER (solo SKINS y
-- WRAPS), las dos versiones PUBLICAS: tienen su propia carpeta, su ventana y su tecla, asi se pueden tener las dos a la vez. herramientas/publicar.py cambia la linea de abajo y, ademas,
-- quita el codigo de los modulos que no van (en lugar de dejarlo apagado) y los cambia por NADA.
local PERFIL = "skins"
local PERFILES = {
    completo = {
        nombre = "Cielo", marca = "CIELO", carpeta = "CieloRoblox", gui = "CieloUI", claves = { "CieloPersonalizado", "SkinsRivals" }, globales = "Cielo", inicial = "cielo",
        secciones = { cielo = true, colores = true, skins = true, wraps = true, dano = true, fps = true, optimizar = true, jugadores = true, config = true },
        teclas = "+ o - la achica a un iconito (y la vuelve a abrir). F8 cielo, F6 colores.",
    },
    sky = {
        nombre = "Zenith Sky Changer", marca = "ZENITH", carpeta = "ZenithSky", gui = "ZenithSkyUI", claves = { "ZenithSkyChanger" }, globales = "ZenithSky", inicial = "cielo",
        secciones = { cielo = true, colores = true, config = true },
        teclas = "+ la achica a un iconito (y la vuelve a abrir). F8 cielo, F6 colores.",
    },
    skins = {
        nombre = "Zenith Skin Changer", marca = "ZENITH", icono = "zenith_skins_icono.png", carpeta = "ZenithSkins", gui = "ZenithSkinsUI", claves = { "ZenithSkinChanger" }, globales = "ZenithSkins", inicial = "skins",
        secciones = { skins = true, wraps = true, config = true },
        teclas = "la tecla - la achica a un iconito (y la vuelve a abrir).",
        -- la paleta de la espada que eligio el usuario (violeta noche, lila claro, verde lima de la guarda): v6.98
        gradiente = { Color3.fromRGB(248, 232, 255), Color3.fromRGB(176, 128, 255), Color3.fromRGB(168, 236, 124) },
        paleta = {
            fondo = Color3.fromRGB(8, 6, 24), panel = Color3.fromRGB(24, 17, 58), panel2 = Color3.fromRGB(46, 34, 100), linea = Color3.fromRGB(76, 58, 142),
            acento = Color3.fromRGB(168, 236, 124), durazno = Color3.fromRGB(190, 146, 255), texto = Color3.fromRGB(244, 236, 255),
            tenue = Color3.fromRGB(172, 156, 214), oscuro = Color3.fromRGB(14, 10, 36),
        },
    },
}
local PF = PERFILES[PERFIL]
local CARPETA = PF.carpeta
-- (v7.00) CONFIGURACION e IDIOMAS: CFG = config.txt; DIC = las traducciones del idioma elegido (nil = español); traducir() cambia un texto en español por el del idioma
local CFG = {}
local DIC = nil
local traducir = function(s) return s end
-- lo que no va en este perfil: los modulos que se quitan se cambian por esto (cualquier funcion existe y no hace nada)
local NADA = setmetatable({
    estado = function() return {} end, cuantas = function() return 0, 0 end, enRivals = function() return false end,
}, { __index = function() return function() end end })
local TECLA_CIELO = Enum.KeyCode.F8
local TECLA_COLORES = Enum.KeyCode.F6
-- tecla + para la ventana. Según el teclado (español, latino, inglés o el del
-- teclado numérico) Roblox la ve con distinto nombre, así que van todas
local TECLAS_VENTANA = {
    [Enum.KeyCode.Equals] = true, [Enum.KeyCode.Plus] = true,
    [Enum.KeyCode.KeypadPlus] = true, [Enum.KeyCode.RightBracket] = true,
}
-- la tecla - (la de SKINS cuando iba aparte) también abre la ventana, directo en SKINS
local TECLAS_SKINS = { [Enum.KeyCode.Minus] = true, [Enum.KeyCode.KeypadMinus] = true }
-- (v6.97) ZENITH SKIN CHANGER usa la tecla - para su ventana; el SKY, la +; asi se pueden tener los dos
if PERFIL == "skins" then
    TECLAS_VENTANA, TECLAS_SKINS = TECLAS_SKINS, {}
elseif PERFIL == "sky" then
    TECLAS_SKINS = {}
end
-- (v7.00) la tecla de la ventana se puede elegir en CONFIGURACION (config.txt: tecla=mas|menos|insert|rshift|home)
local TECLAS_ELEGIBLES = {
    { "mas", "+", { Enum.KeyCode.Equals, Enum.KeyCode.Plus, Enum.KeyCode.KeypadPlus, Enum.KeyCode.RightBracket } },
    { "menos", "-", { Enum.KeyCode.Minus, Enum.KeyCode.KeypadMinus } },
    { "insert", "Insert", { Enum.KeyCode.Insert } },
    { "rshift", "Right Shift", { Enum.KeyCode.RightShift } },
    { "home", "Home", { Enum.KeyCode.Home } },
}
local NOMBRE_TECLA = (PERFIL == "skins") and "-" or "+"

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local jugador = Players.LocalPlayer

-- si ya había uno corriendo (este, o el SKINS de antes que iba aparte), se apaga
-- antes de guardar "lo original". Se busca en los tres lugares posibles: según el
-- executor, getgenv() puede no ser el mismo entre una ejecución y otra
local env = (getgenv and getgenv()) or _G
local registros = { env, shared, _G }
for _, tabla in ipairs(registros) do
    if type(tabla) == "table" then
        for _, clave in ipairs(PF.claves) do
            local anterior = rawget(tabla, clave)
            if anterior then
                pcall(anterior.Limpiar)
                rawset(tabla, clave, nil)
            end
        end
    end
end

-- skins.lua (la pestaña vieja de Xeno) pide abrir la ventana directo en SKINS, y el
-- autoexec (se ejecuta solo al entrar a Rivals) pide empezar achicada, en el iconito
local pestanaInicial, inicioAchicado = nil, false
for _, tabla in ipairs(registros) do
    if type(tabla) == "table" then
        if rawget(tabla, PF.globales .. "PestanaInicial") then
            pestanaInicial = rawget(tabla, PF.globales .. "PestanaInicial")
            rawset(tabla, PF.globales .. "PestanaInicial", nil)
        end
        if rawget(tabla, PF.globales .. "InicioAchicado") then
            inicioAchicado = true
            rawset(tabla, PF.globales .. "InicioAchicado", nil)
        end
    end
end

local function contenedoresGui()
    local lista = {}
    if gethui then pcall(function() table.insert(lista, gethui()) end) end
    pcall(function() table.insert(lista, game:GetService("CoreGui")) end)
    pcall(function() table.insert(lista, jugador:FindFirstChildOfClass("PlayerGui")) end)
    return lista
end

-- y por si quedó alguna ventana de una versión vieja que no se dejó apagar
-- (la del cielo o la de SKINS), se borra igual
local function borrarVentanasViejas(menos)
    for _, contenedor in ipairs(contenedoresGui()) do
        pcall(function()
            for _, hijo in ipairs(contenedor:GetChildren()) do
                if (hijo.Name == PF.gui or (PERFIL == "completo" and hijo.Name == "SkinsUI")) and hijo ~= menos then hijo:Destroy() end
            end
        end)
    end
end
borrarVentanasViejas(nil)

local function aviso(texto)
    warn("[Cielo] " .. texto)
    if CFG.avisos == "0" then return end -- CONFIGURACION: avisos en pantalla apagados
    pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
        Title = PF.nombre .. " " .. VERSION,
        Text = traducir(texto),
        Duration = 5,
    })
end

-- Funciones del executor ----------------------------------------------------

local cargarAsset = getcustomasset or getsynasset
local disponibles = {
    readfile = readfile, writefile = writefile, listfiles = listfiles,
    isfolder = isfolder, makefolder = makefolder, getcustomasset = cargarAsset,
}
local faltan = {}
for _, nombreFuncion in ipairs({ "readfile", "writefile", "listfiles", "isfolder", "makefolder", "getcustomasset" }) do
    if type(disponibles[nombreFuncion]) ~= "function" then
        table.insert(faltan, nombreFuncion)
    end
end
if #faltan > 0 then
    aviso("A tu executor le falta: " .. table.concat(faltan, ", "))
    return
end

-- Archivos -------------------------------------------------------------------

local function ruta(...)
    return table.concat({ CARPETA, ... }, "/")
end

local function leer(r)
    local ok, texto = pcall(readfile, r)
    if ok and type(texto) == "string" then
        return texto
    end
    return nil
end

local function escribir(r, texto)
    pcall(writefile, r, texto)
end

local function esCarpeta(r)
    local ok, si = pcall(isfolder, r)
    return ok and si == true
end

if not esCarpeta(CARPETA) then pcall(makefolder, CARPETA) end
if not esCarpeta(ruta("cielos")) then pcall(makefolder, ruta("cielos")) end

-- Configuracion (v7.00) --------------------------------------------------------
for linea in (leer(ruta("config.txt")) or ""):gmatch("[^\r\n]+") do
    local clave, valor = linea:match("^(%w+)=(.*)$")
    if clave then CFG[clave] = valor end
end
local function guardarConfig()
    local t = {}
    for clave, valor in pairs(CFG) do table.insert(t, clave .. "=" .. tostring(valor)) end
    table.sort(t)
    escribir(ruta("config.txt"), table.concat(t, "\n"))
end
local IDIOMAS = { { "en", "English" }, { "es", "Español (México)" }, { "ru", "Русский" }, { "pt", "Português (Brasil)" } }
local IDIOMA = CFG.idioma
local idiomaValido = false
for _, par in ipairs(IDIOMAS) do if par[1] == IDIOMA then idiomaValido = true end end
if not idiomaValido then
    -- sin eleccion: el de Roblox (es, pt, ru o ingles); el script del usuario sigue en español
    local ok, id = pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end)
    id = ok and tostring(id):lower():sub(1, 2) or ""
    IDIOMA = (PERFIL == "completo") and "es" or ((id == "es" or id == "pt" or id == "ru") and id or "en")
end
if IDIOMA ~= "es" then
    local ok, tabla = pcall(function() return loadstring(leer(ruta("idiomas.lua")) or "return {}", "=idiomas")() end)
    DIC = (ok and type(tabla) == "table") and tabla[IDIOMA] or nil
end
if DIC then
    local fragmentos = {}
    for clave in pairs(DIC) do
        if #clave >= 8 then table.insert(fragmentos, clave) end
    end
    table.sort(fragmentos, function(a, b) return #a > #b end)
    -- el texto entero, o (si es una frase armada con pedazos, "En la mano: " + el arma) cada pedazo conocido
    traducir = function(s)
        if type(s) ~= "string" or s == "" then return s end
        local t = DIC[s]
        if t then return t end
        for _, clave in ipairs(fragmentos) do
            local i, j = s:find(clave, 1, true)
            if i then s = s:sub(1, i - 1) .. DIC[clave] .. s:sub(j + 1) end
        end
        return s
    end
end

-- Ventana ----------------------------------------------------------------------
-- Grande (más de un tercio de la pantalla), se mueve desde la cabecera, cambia de
-- tamaño desde la esquina de abajo y con "–" se vuelve un iconito del cielo.

local C = {
    fondo = Color3.fromRGB(19, 15, 27),
    panel = Color3.fromRGB(34, 27, 46),
    panel2 = Color3.fromRGB(49, 39, 66),
    linea = Color3.fromRGB(58, 46, 78),
    acento = Color3.fromRGB(195, 155, 255),
    durazno = Color3.fromRGB(255, 201, 163),
    texto = Color3.fromRGB(241, 234, 249),
    tenue = Color3.fromRGB(164, 151, 181),
    oscuro = Color3.fromRGB(24, 17, 34),
}
if PF.paleta then
    for clave, color in pairs(PF.paleta) do C[clave] = color end
end

-- (v6.92) la letra de toda la ventana es Nunito (redonda, como la maqueta C): el codigo sigue pidiendo Gotham, Gotham Bold... y aqui se cambia por Nunito con el mismo peso
local FAMILIA_LETRA = (IDIOMA == "ru") and "rbxasset://fonts/families/SourceSansPro.json" or "rbxasset://fonts/families/Nunito.json" -- (v7.00) Nunito no tiene cirilico
local PESOS_LETRA = {
    [Enum.Font.Gotham] = Enum.FontWeight.Regular, [Enum.Font.GothamMedium] = Enum.FontWeight.Medium,
    [Enum.Font.GothamBold] = Enum.FontWeight.Bold, [Enum.Font.GothamBlack] = Enum.FontWeight.ExtraBold,
}
local function ponerLetra(obj, valor)
    local peso = PESOS_LETRA[valor]
    if not peso then
        obj.Font = valor
        return
    end
    local ok = pcall(function() obj.FontFace = Font.new(FAMILIA_LETRA, peso) end)
    if not ok then pcall(function() obj.Font = Enum.Font.Nunito end) end
end

local function crear(clase, props, hijos)
    local obj = Instance.new(clase)
    for clave, valor in pairs(props or {}) do
        if clave == "Font" then
            ponerLetra(obj, valor)
        elseif clave ~= "Parent" then
            obj[clave] = valor
        end
    end
    for _, hijo in ipairs(hijos or {}) do hijo.Parent = obj end
    -- (v7.00) idioma: el texto en español se cambia por el del idioma elegido, y lo mismo cada vez que el codigo lo cambie
    if DIC then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local function aplicar()
                local t = traducir(obj.Text)
                if t ~= obj.Text then obj.Text = t end
            end
            aplicar()
            obj:GetPropertyChangedSignal("Text"):Connect(aplicar)
        elseif obj:IsA("TextBox") then
            obj.PlaceholderText = traducir(obj.PlaceholderText)
        end
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function esquina(px)
    return crear("UICorner", { CornerRadius = UDim.new(0, px) })
end

local function trazo(color, grosor, transparencia)
    return crear("UIStroke", {
        Color = color, Thickness = grosor, Transparency = transparencia or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

-- oscurece la parte de abajo de una imagen para que se lea el texto encima
local function sombraAbajo(padre, radio)
    return crear("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0, Parent = padre,
    }, {
        esquina(radio),
        crear("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.55, 1),
                NumberSequenceKeypoint.new(1, 0.25),
            }),
        }),
    })
end

local function padreGui()
    if gethui then
        local ok, contenedor = pcall(gethui)
        if ok and contenedor then return contenedor end
    end
    local ok, coreGui = pcall(function()
        local cg = game:GetService("CoreGui")
        local prueba = Instance.new("Folder")
        prueba.Parent = cg
        prueba:Destroy()
        return cg
    end)
    if ok and coreGui then return coreGui end
    return jugador:WaitForChild("PlayerGui")
end

-- las imágenes que deja la app: el iconito y la franja de la cabecera ("nubes moradas")
local function imagenPropia(archivo)
    local ok, id = pcall(cargarAsset, ruta(archivo))
    return (ok and type(id) == "string") and id or ""
end
-- (v6.99) cada perfil carga SU icono con un nombre propio: getcustomasset del ejecutor se acuerda del nombre del archivo, y si dos carpetas tienen un "icono.png" distinto sale el del primero que se cargo
local IMG_ICONO = imagenPropia(PF.icono or "icono.png")
local IMG_BANNER = imagenPropia("banner.png")

-- El material que tenían las partes que el optimizador alisó (SmoothPlastic). Las reglas de COLORES se
-- guardan por material, así que miran aquí para seguir encontrando sus bloques.
local materialOriginal = setmetatable({}, { __mode = "k" })
local function materialDe(parte)
    return (materialOriginal[parte] or parte.Material).Name
end

local LATERAL = 108                    -- ancho del riel de la izquierda (v6.92, rediseno C; v6.93: 68 -> 86; v6.95: 108, con el nombre de cada seccion escrito)
local CABECERA = 58                    -- alto de la barra de arriba (v6.92: ya no lleva la franja de nubes)
local MINIMO = Vector2.new(720, 700)   -- lo más chica que se puede achicar arrastrando (la barra de la izquierda cabe justo)

local vivo = true
local conexionesUI = {}
local alCambiarVentana = {} -- avisos para las páginas: se cambió de página, se achicó...
local alCambiarEstado = {}  -- avisos cuando se prende o apaga el cielo o los colores

-- Una barrita chica para elegir un número arrastrando: el título y el valor arriba, la barra
-- abajo. alCambiar(v) mientras se arrastra; alSoltar(v) al soltar (ahí se guarda o se aplica).
-- Devuelve una función para pintarla con otro valor.
local function barrita(padre, posicion, ancho, titulo, minimo, maximo, valor, alCambiar, alSoltar)
    local marco = crear("Frame", {
        Position = posicion, Size = ancho, BackgroundTransparency = 1, Parent = padre,
    })
    crear("TextLabel", {
        Size = UDim2.new(0.65, 0, 0, 14), Text = titulo, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.tenue, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = marco,
    })
    local etiqueta = crear("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.35, 0, 0, 14),
        Text = "", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.acento,
        TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = marco,
    })
    local pista = crear("TextButton", {
        Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 8), Text = "", AutoButtonColor = false,
        BackgroundColor3 = C.panel2, Parent = marco,
    }, { crear("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local lleno = crear("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = pista,
    }, {
        crear("UICorner", { CornerRadius = UDim.new(1, 0) }),
        crear("UIGradient", { Color = ColorSequence.new(C.acento, C.durazno) }),
    })
    local perilla = crear("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = C.texto, Parent = pista,
    }, { crear("UICorner", { CornerRadius = UDim.new(1, 0) }), trazo(C.oscuro, 2, 0) })
    local actual = valor
    local function pintar(v)
        actual = v
        local f = (v - minimo) / (maximo - minimo)
        lleno.Size = UDim2.fromScale(f, 1)
        perilla.Position = UDim2.fromScale(f, 0.5)
        etiqueta.Text = tostring(v) .. "%"
    end
    pintar(valor)
    local arrastrando = false
    local function leerMouse()
        local x = UserInputService:GetMouseLocation().X
        local f = math.clamp((x - pista.AbsolutePosition.X) / math.max(pista.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor(minimo + f * (maximo - minimo) + 0.5)
        if v ~= actual then
            pintar(v)
            alCambiar(v)
        end
    end
    pista.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastrando = true
            leerMouse()
        end
    end)
    table.insert(conexionesUI, UserInputService.InputChanged:Connect(function(input)
        if arrastrando and input.UserInputType == Enum.UserInputType.MouseMovement then leerMouse() end
    end))
    table.insert(conexionesUI, UserInputService.InputEnded:Connect(function(input)
        if arrastrando and input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastrando = false
            if alSoltar then alSoltar(actual) end
        end
    end))
    return pintar
end

-- Los botones que dejan algo "como estaba": el primer toque pide confirmación (el botón queda rojo
-- 3 segundos) y el segundo lo hace. Así un clic sin querer no borra nada.
local function conConfirmacion(boton, accion, textoSeguro)
    local texto, fondo, color, tam = boton.Text, boton.BackgroundColor3, boton.TextColor3, boton.TextSize
    local armado = 0
    local function volver()
        armado = 0
        boton.Text, boton.BackgroundColor3, boton.TextColor3, boton.TextSize = texto, fondo, color, tam
    end
    boton.MouseButton1Click:Connect(function()
        if armado > 0 and os.clock() - armado < 3 then
            volver()
            accion()
            return
        end
        armado = os.clock()
        local esta = armado
        boton.Text = textoSeguro or "¿Seguro? Toca otra vez"
        boton.TextSize = boton:GetAttribute("TamArmado") or boton.TextSize
        boton.BackgroundColor3 = Color3.fromRGB(255, 120, 140)
        boton.TextColor3 = C.oscuro
        task.delay(3, function()
            if armado == esta then volver() end
        end)
    end)
end

local function avisarEstado()
    for _, alCambiar in ipairs(alCambiarEstado) do pcall(alCambiar) end
end

local gui = crear("ScreenGui", {
    Name = PF.gui, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local ventana = crear("Frame", {
    Name = "Ventana", Active = true, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = gui,
}, {
    esquina(20), trazo(C.acento, 1, 0.5),
    crear("UIGradient", { Rotation = 150, Color = ColorSequence.new(C.fondo:Lerp(Color3.new(1, 1, 1), 0.07), C.fondo) }),
})
local escalaUI = crear("UIScale", { Scale = math.clamp((tonumber(CFG.escala) or 100) / 100, 0.8, 1.3), Parent = ventana }) -- (v7.00) CONFIGURACION: tamaño de la ventana

-- (v6.92, rediseno C: riel de iconos, barra de arriba limpia y tarjetas grandes; colores de la A)
-- la barra de arriba (desde aqui se arrastra la ventana): el nombre de la pagina, el arma, la version y los botones
local cabecera = crear("Frame", {
    Name = "Cabecera", Active = true, Position = UDim2.fromOffset(LATERAL, 0), Size = UDim2.new(1, -LATERAL, 0, CABECERA),
    BackgroundTransparency = 1, Parent = ventana,
})
local tituloPagina = crear("TextLabel", {
    Text = "Cielo", Font = Enum.Font.GothamBlack, TextSize = 23, TextColor3 = C.texto,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 5), Size = UDim2.new(1, -330, 0, 28), Parent = cabecera,
})
-- (v6.95) lo que sirve la seccion, escrito debajo del nombre
if PF.gradiente then -- el titulo de la pagina con el degradado de la espada
    crear("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, PF.gradiente[1]), ColorSequenceKeypoint.new(0.55, PF.gradiente[2]), ColorSequenceKeypoint.new(1, PF.gradiente[3]),
        }),
    }).Parent = tituloPagina
end
local descripcionPagina = crear("TextLabel", {
    Text = "", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.tenue,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 33), Size = UDim2.new(1, -330, 0, 18), Parent = cabecera,
})
local derechaTop = crear("Frame", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -92, 0.5, 0), Size = UDim2.fromOffset(0, 28),
    AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = cabecera,
}, {
    crear("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
    }),
})
local contextoTop = crear("TextLabel", { -- el arma en la mano (solo en SKINS y WRAPS)
    LayoutOrder = 1, Text = "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.tenue,
    BackgroundColor3 = C.panel, Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, Visible = false,
    Parent = derechaTop,
}, { esquina(14), trazo(C.linea, 1, 0), crear("UIPadding", { PaddingLeft = UDim.new(0, 13), PaddingRight = UDim.new(0, 13) }) })
local pildoraVersion = crear("TextLabel", {
    LayoutOrder = 2, Text = VERSION, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.tenue, BackgroundColor3 = C.panel,
    Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, Parent = derechaTop,
}, { esquina(13), trazo(C.linea, 1, 0), crear("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }) })

local function botonCabecera(texto, x, tamTexto)
    local boton = crear("TextButton", {
        Text = texto, Font = Enum.Font.GothamBold, TextSize = tamTexto, TextColor3 = C.texto,
        BackgroundColor3 = C.panel, AutoButtonColor = false,
        Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, x, 0.5, -17), Parent = cabecera,
    }, { esquina(12), trazo(C.linea, 1, 0) })
    boton.MouseEnter:Connect(function() boton.BackgroundColor3 = C.panel2 end)
    boton.MouseLeave:Connect(function() boton.BackgroundColor3 = C.panel end)
    return boton
end
local botonMinimizar = botonCabecera("–", -88, 20)
local botonCerrar = botonCabecera("×", -48, 22)

-- el riel de la izquierda: el logo arriba, las ocho secciones (solo iconos; el nombre sale al pasar el mouse) y abajo los atajos
local riel = crear("Frame", {
    Name = "Riel", Size = UDim2.new(0, LATERAL, 1, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0, Parent = ventana,
}, { esquina(20) })
crear("Frame", { -- tapa el redondeo del lado de adentro
    Position = UDim2.new(1, -20, 0, 0), Size = UDim2.new(0, 20, 1, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0, Parent = riel,
})
crear("Frame", { -- la raya que separa el riel del contenido
    Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = C.linea, BorderSizePixel = 0, Parent = riel,
})
local logoRiel = crear("ImageLabel", {
    Image = IMG_ICONO, ScaleType = Enum.ScaleType.Crop, BackgroundColor3 = C.panel2, BorderSizePixel = 0,
    Position = UDim2.fromOffset((LATERAL - 46) / 2, 8), Size = UDim2.fromOffset(46, 46), Parent = riel,
}, { esquina(15), trazo(C.acento, 1.5, 0.3) })
if IMG_ICONO == "" then
    crear("TextLabel", {
        Text = "☁️", Font = Enum.Font.GothamBold, TextSize = 20, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Parent = logoRiel,
    })
end
crear("TextLabel", {
    Text = PF.marca, Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = C.acento, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 55), Size = UDim2.new(1, 0, 0, 16), Parent = riel,
})
logoRiel:SetAttribute("Tip", PF.nombre .. " " .. VERSION .. "  ·  solo lo ves tú")

local navegacion = crear("Frame", {
    Position = UDim2.fromOffset(0, 76), Size = UDim2.new(1, 0, 0, 470), BackgroundTransparency = 1, Parent = riel,
}, {
    crear("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }),
})
local function separadorRiel(orden)
    if PERFIL ~= "completo" then return end
    crear("Frame", {
        LayoutOrder = orden, Size = UDim2.fromOffset(72, 1), BackgroundColor3 = C.linea, BorderSizePixel = 0, Parent = navegacion,
    })
end

-- los atajos de abajo (cielo, colores y daño prendidos o apagados; "todo como estaba"): botones cuadrados, el estado se ve en el color
local atajos = crear("Frame", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), Size = UDim2.new(1, 0, 0, 4 * 30 + 3 * 3),
    BackgroundTransparency = 1, Parent = riel,
}, {
    crear("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    }),
})
local function atajo(orden)
    return crear("TextButton", {
        LayoutOrder = orden, Size = UDim2.fromOffset(96, 30), Font = Enum.Font.GothamBold, TextSize = 11,
        Text = "", AutoButtonColor = false, BackgroundColor3 = C.panel2, Parent = atajos,
    }, { esquina(12) })
end
local atajoCielo = atajo(1)
local atajoColores = atajo(2)
local atajoDano = atajo(3)
-- deja todo como estaba el juego (con confirmacion; se conecta al final, cuando ya estan los modulos)
local atajoTodo = atajo(4)
atajoTodo.Text = "🔄 Como estaba"
atajoTodo.TextColor3 = C.texto
atajoTodo:SetAttribute("TamArmado", 10)
atajoTodo:SetAttribute("Tip", "Deja TODO como estaba: cielo, colores, armas y graficos (toca dos veces)")
trazo(Color3.fromRGB(255, 120, 140), 1, 0.4).Parent = atajoTodo

-- el globo de ayuda: el nombre de lo que tiene el mouse encima (atributo "Tip")
local globo = crear("Frame", {
    Visible = false, ZIndex = 80, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(0, 28),
    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.oscuro, BorderSizePixel = 0, Parent = ventana,
}, { esquina(9), trazo(C.acento, 1, 0.5), crear("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
local globoTexto = crear("TextLabel", {
    ZIndex = 81, Text = "", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.texto, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, Parent = globo,
})
local function conGlobo(boton)
    boton.MouseEnter:Connect(function()
        local texto = boton:GetAttribute("Tip")
        if not texto then return end
        globoTexto.Text = texto
        globo.Position = UDim2.fromOffset(LATERAL + 8, boton.AbsolutePosition.Y - ventana.AbsolutePosition.Y + boton.AbsoluteSize.Y / 2)
        globo.Visible = true
    end)
    boton.MouseLeave:Connect(function() globo.Visible = false end)
end
-- (v6.97) en cada perfil solo estan los atajos de lo que trae
atajoCielo.Visible = PF.secciones.cielo == true
atajoColores.Visible = PF.secciones.colores == true
atajoDano.Visible = PF.secciones.dano == true
for _, b in ipairs({ logoRiel, atajoCielo, atajoColores, atajoDano, atajoTodo }) do
    if b:IsA("GuiObject") then
        b.Active = true
        conGlobo(b)
    end
end

-- el contenido: una página por sección
local zonaPaginas = crear("Frame", {
    Name = "Contenido", Position = UDim2.fromOffset(LATERAL, CABECERA),
    Size = UDim2.new(1, -LATERAL, 1, -CABECERA), BackgroundTransparency = 1, Parent = ventana,
}, {
    crear("UIPadding", {
        PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 16),
    }),
})

local function pagina(nombrePagina)
    return crear("Frame", {
        Name = nombrePagina, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Visible = false, Parent = zonaPaginas,
    })
end

local paginaCielo = pagina("Cielo")
local paginaColores = pagina("Colores")
local paginaSkins = pagina("Skins") -- SKINS y WRAPS usan la misma página
local paginaDano = pagina("Dano")   -- la configuración del contador de daño
local paginaFps = pagina("Fps")     -- rendimiento: contador de FPS y lo que se puede aligerar
local paginaOptimizar = pagina("Optimizar") -- el super optimizador para servers llenos
local paginaJugadores = pagina("Jugadores") -- la gente del server, para reportar
local paginaConfig = pagina("Config")     -- (v7.00) idioma y opciones de la ventana
local paginas = {
    cielo = paginaCielo, colores = paginaColores, skins = paginaSkins, wraps = paginaSkins, dano = paginaDano,
    fps = paginaFps, optimizar = paginaOptimizar, jugadores = paginaJugadores, config = paginaConfig,
}
local paginaActual = PF.inicial
local estadoVentana = "abierta" -- "abierta", "icono" (achicada) u "oculta" (con la ×)
local botonesPestana = {}
local refrescarVentana -- más abajo

local function abierta()
    return estadoVentana == "abierta"
end

local TITULOS_PAGINA = {
    cielo = "Cielo", colores = "Colores", skins = "Skins", wraps = "Wraps", dano = "Daño", fps = "FPS", optimizar = "Optimizar", jugadores = "Jugadores", config = "Configuración",
}
local ALTO_PESTANA = (PERFIL == "completo") and 46 or 54 -- (v7.00) con 9 secciones los botones son un poco mas bajos
-- (v6.95) para qué sirve cada seccion: se ve debajo del nombre en la barra de arriba y en el globo al pasar el mouse
local DESCRIPCION_PAGINA = {
    cielo = "Pon una foto tuya como cielo del juego",
    colores = "Pinta los bloques del mapa de otro color",
    skins = "Cambia el aspecto de tus armas con skins",
    wraps = "Ponle un forro (material o diseño) a tus armas",
    dano = "Contador de daño en pantalla",
    fps = "Contador de FPS y ajustes para ir mas fluido",
    optimizar = "Modo para servers llenos: baja detalles para que no se trabe",
    jugadores = "La gente del server, para reportar a alguien",
    config = "Idioma y opciones de la ventana",
}
local function pestana(nombrePestana, simbolo, texto, orden)
    if not PF.secciones[nombrePestana] then return end -- (v6.97) esta seccion no va en este perfil
    local boton = crear("TextButton", {
        LayoutOrder = orden, Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(96, ALTO_PESTANA),
        BackgroundColor3 = C.panel2, BackgroundTransparency = 1, Parent = navegacion,
    }, { esquina(14) })
    boton:SetAttribute("Tip", DESCRIPCION_PAGINA[nombrePestana] or texto)
    local marca = crear("Frame", { -- (ya no hay marca al lado: la pestana activa se pinta entera)
        Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Visible = false, Parent = boton,
    })
    crear("TextLabel", { -- el icono
        Text = simbolo, Font = Enum.Font.GothamBold, TextSize = 24, TextColor3 = C.texto,
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, ALTO_PESTANA - 22), Parent = boton,
    })
    local etiqueta = crear("TextLabel", { -- el nombre
        Text = TITULOS_PAGINA[nombrePestana] or texto, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.tenue,
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, ALTO_PESTANA - 19), Size = UDim2.new(1, 0, 0, 17), Parent = boton,
    })
    boton.MouseEnter:Connect(function()
        if paginaActual ~= nombrePestana then boton.BackgroundTransparency = 0.6 end
    end)
    boton.MouseLeave:Connect(function()
        if paginaActual ~= nombrePestana then boton.BackgroundTransparency = 1 end
    end)
    conGlobo(boton)
    boton.MouseButton1Click:Connect(function()
        paginaActual = nombrePestana
        refrescarVentana()
    end)
    botonesPestana[nombrePestana] = { boton = boton, marca = marca, etiqueta = etiqueta }
end
pestana("cielo", "☁️", "CIELO", 1)
pestana("colores", "🎨", "COLORES", 2)
separadorRiel(3)
pestana("skins", "🔫", "SKINS", 4)
pestana("wraps", "✨", "WRAPS", 5)
pestana("dano", "🎯", "DAÑO", 6)
separadorRiel(7)
pestana("fps", "⚡", "FPS", 8)
pestana("optimizar", "🚀", "OPTIMIZAR", 9)
separadorRiel(10)
pestana("jugadores", "👥", "JUGADORES", 11)
separadorRiel(12)
pestana("config", "⚙️", "CONFIGURACION", 13) -- (v7.00) en todos los perfiles

-- la esquina de abajo a la derecha: arrastrarla cambia el tamaño
local asaTamano = crear("TextButton", {
    Text = "◢", FontFace = Font.fromEnum(Enum.Font.GothamBold), TextSize = 14, TextColor3 = C.tenue, AutoButtonColor = false,
    BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, -4),
    Size = UDim2.fromOffset(20, 20), ZIndex = 10, Parent = ventana,
})

-- la ventana achicada: el iconito del cielo. Se puede mover; con un clic vuelve la ventana
local LADO_ICONO = 40
local burbuja = crear("ImageButton", {
    Name = "Iconito", Image = IMG_ICONO, ScaleType = Enum.ScaleType.Crop, AutoButtonColor = false,
    Visible = false, BackgroundColor3 = C.panel2, Size = UDim2.fromOffset(LADO_ICONO, LADO_ICONO), Parent = gui,
}, { esquina(12), trazo(C.acento, 1.5, 0.2) })
if IMG_ICONO == "" then
    crear("TextLabel", {
        Text = "☁️", Font = Enum.Font.GothamBold, TextSize = 20, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Parent = burbuja,
    })
end

-- Mouse: con la ventana abierta se suelta (en Rivals y juegos de primera persona queda
-- trabado al centro); achicada o escondida se devuelve como estaba. Se fuerza cada cuadro
-- después de los scripts del juego, porque muchos lo vuelven a trabar solos.
local mouseDelJuego = nil -- { comportamiento, icono } de antes de soltarlo

local function primeraPersona()
    -- (v7.01) solo cuenta la camara pegada a la cabeza: CameraMode / CameraMaxZoomDistance tambien valen en el lobby de Rivals
    local camara = workspace.CurrentCamera
    local personaje = jugador.Character
    if not (camara and personaje) then return false end
    for _, nombreParte in ipairs({ "Head", "HumanoidRootPart" }) do
        local parte = personaje:FindFirstChild(nombreParte)
        if parte and parte:IsA("BasePart") and (camara.CFrame.Position - parte.Position).Magnitude < 3.5 then
            return true
        end
    end
    return false
end

local function soltarRender(nombreRender)
    pcall(function() RunService:UnbindFromRenderStep(nombreRender) end)
end

local function mouseLibre(libre)
    if libre and not mouseDelJuego then
        soltarRender("CieloTrabarMouse")
        mouseDelJuego = { UserInputService.MouseBehavior, UserInputService.MouseIconEnabled }
        RunService:BindToRenderStep("CieloSoltarMouse", Enum.RenderPriority.Last.Value + 1, function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
    elseif not libre and mouseDelJuego then
        soltarRender("CieloSoltarMouse")
        local comportamiento, icono = mouseDelJuego[1], mouseDelJuego[2]
        mouseDelJuego = nil

        -- (v7.01) solo se devuelve LockCenter (primera persona) o Default. LockCurrentPosition es el
        -- de "mantener clic derecho para girar": si se guardaba y se devolvia, el mouse quedaba trabado
        -- girando la camara sin clic. El juego lo vuelve a poner solo cuando aprietas el clic derecho.
        -- Trabado = el juego lo tenia en LockCenter, o el cursor invisible, o la camara pegada a la cabeza
        -- (aunque haya quedado suelto por culpa de otra cosa)
        local cerca = primeraPersona()
        local trabar = comportamiento == Enum.MouseBehavior.LockCenter or icono == false or cerca
        pcall(escribir, ruta("raton_log.txt"), string.format("antes=%s icono=%s camaraCerca=%s -> %s",
            tostring(comportamiento), tostring(icono), tostring(cerca), trabar and "LockCenter" or "Default"))
        comportamiento = trabar and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        UserInputService.MouseBehavior = comportamiento
        UserInputService.MouseIconEnabled = icono

        -- por si el juego lo vuelve a soltar justo después, se vigila 2 segundos
        if trabar then
            local hasta = os.clock() + 2
            RunService:BindToRenderStep("CieloTrabarMouse", Enum.RenderPriority.Last.Value + 1, function()
                if os.clock() > hasta then
                    soltarRender("CieloTrabarMouse")
                elseif UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
                    UserInputService.MouseBehavior = comportamiento
                end
            end)
        end
    end
end

refrescarVentana = function()
    ventana.Visible = estadoVentana == "abierta"
    burbuja.Visible = estadoVentana == "icono"
    mouseLibre(estadoVentana == "abierta")
    local visible = paginas[paginaActual]
    for _, p in ipairs({ paginaCielo, paginaColores, paginaSkins, paginaDano, paginaFps, paginaOptimizar, paginaJugadores, paginaConfig }) do
        p.Visible = p == visible
    end
    for nombrePestana, b in pairs(botonesPestana) do
        local activa = nombrePestana == paginaActual
        b.boton.BackgroundColor3 = activa and C.acento or C.panel2
        b.boton.BackgroundTransparency = activa and 0 or 1
        b.etiqueta.TextColor3 = activa and C.oscuro or C.tenue
        b.marca.Visible = false
    end
    tituloPagina.Text = TITULOS_PAGINA[paginaActual] or ""
    descripcionPagina.Text = DESCRIPCION_PAGINA[paginaActual] or ""
    contextoTop.Visible = (paginaActual == "skins" or paginaActual == "wraps") and contextoTop.Text ~= ""
    for _, alCambiar in ipairs(alCambiarVentana) do
        local ok, fallo = pcall(alCambiar)
        if not ok then warn("[Cielo] " .. tostring(fallo)) end
    end
end

local function abrirVentana(nombrePagina)
    estadoVentana = "abierta"
    if nombrePagina then paginaActual = nombrePagina end
    refrescarVentana()
end

local function achicarVentana()
    estadoVentana = "icono"
    refrescarVentana()
end

local function sobreVentana(p)
    local a, t = ventana.AbsolutePosition, ventana.AbsoluteSize
    return ventana.Visible and p.X >= a.X and p.X <= a.X + t.X and p.Y >= a.Y and p.Y <= a.Y + t.Y
end

-- Dónde está y de qué tamaño (se guarda en ventana.txt para la próxima vez) -------------

local function pantalla()
    local camara = workspace.CurrentCamera
    return camara and camara.ViewportSize or Vector2.new(1280, 720)
end

local function entre(v, minimo, maximo)
    if maximo < minimo then maximo = minimo end
    return math.max(minimo, math.min(maximo, v))
end

local geo = {}
do
    local n = {}
    for v in (leer(ruta("ventana.txt")) or ""):gmatch("-?%d+") do table.insert(n, tonumber(v)) end
    if #n >= 6 then geo = { x = n[1], y = n[2], w = n[3], h = n[4], bx = n[5], by = n[6] } end
end

local function guardarGeo()
    escribir(ruta("ventana.txt"), table.concat({ geo.x, geo.y, geo.w, geo.h, geo.bx, geo.by }, " "))
end

-- que todo quepa en la pantalla (y los tamaños de la primera vez)
local function acomodar()
    local p = pantalla()
    geo.w = math.floor(entre(geo.w or p.X * 0.42, math.min(MINIMO.X, p.X - 16), p.X - 16))
    geo.h = math.floor(entre(geo.h or p.Y * 0.78, math.min(MINIMO.Y, p.Y - 16), p.Y - 16))
    geo.x = math.floor(entre(geo.x or (p.X - geo.w - 28), 8, p.X - geo.w - 8))
    geo.y = math.floor(entre(geo.y or ((p.Y - geo.h) / 2), 8, p.Y - geo.h - 8))
    geo.bx = math.floor(entre(geo.bx or (p.X - 90), 8, p.X - LADO_ICONO - 8))
    geo.by = math.floor(entre(geo.by or (p.Y * 0.3), 8, p.Y - LADO_ICONO - 8))
    ventana.Size = UDim2.fromOffset(geo.w, geo.h)
    ventana.Position = UDim2.fromOffset(geo.x, geo.y)
    burbuja.Position = UDim2.fromOffset(geo.bx, geo.by)
end

-- arrastrar algo con el mouse: alMover recibe cuánto se movió desde que se apretó
local function arrastrable(asa, alEmpezar, alMover, alSoltar)
    asa.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local inicio = input.Position
        local movido = false
        alEmpezar()
        local mover = UserInputService.InputChanged:Connect(function(cambio)
            if cambio.UserInputType == Enum.UserInputType.MouseMovement
                or cambio.UserInputType == Enum.UserInputType.Touch then
                local d = cambio.Position - inicio
                if movido or d.Magnitude > 4 then
                    movido = true
                    alMover(Vector2.new(d.X, d.Y))
                end
            end
        end)
        local fin
        fin = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mover:Disconnect()
                fin:Disconnect()
                alSoltar(movido)
            end
        end)
    end)
end

do
    local x0, y0, w0, h0, bx0, by0 = 0, 0, 0, 0, 0, 0
    -- mover la ventana desde la cabecera
    arrastrable(cabecera, function() x0, y0 = geo.x, geo.y end, function(d)
        local p = pantalla()
        geo.x = math.floor(entre(x0 + d.X, 0, p.X - geo.w))
        geo.y = math.floor(entre(y0 + d.Y, 0, p.Y - geo.h))
        ventana.Position = UDim2.fromOffset(geo.x, geo.y)
    end, function(movido)
        if movido then guardarGeo() end
    end)
    -- cambiar el tamaño desde la esquina
    arrastrable(asaTamano, function() w0, h0 = geo.w, geo.h end, function(d)
        local p = pantalla()
        geo.w = math.floor(entre(w0 + d.X, math.min(MINIMO.X, p.X - 16), p.X - geo.x - 4))
        geo.h = math.floor(entre(h0 + d.Y, math.min(MINIMO.Y, p.Y - 16), p.Y - geo.y - 4))
        ventana.Size = UDim2.fromOffset(geo.w, geo.h)
    end, function(movido)
        if movido then guardarGeo() end
    end)
    -- el iconito: arrastrado se mueve; con un clic (sin moverlo) vuelve la ventana
    arrastrable(burbuja, function() bx0, by0 = geo.bx, geo.by end, function(d)
        local p = pantalla()
        geo.bx = math.floor(entre(bx0 + d.X, 4, p.X - LADO_ICONO - 4))
        geo.by = math.floor(entre(by0 + d.Y, 4, p.Y - LADO_ICONO - 4))
        burbuja.Position = UDim2.fromOffset(geo.bx, geo.by)
    end, function(movido)
        if movido then
            guardarGeo()
        else
            abrirVentana()
        end
    end)
end

-- ============================================================================
-- CRISTAL (el reflejo del cielo)
-- ============================================================================
-- Cada superficie grande del mapa lleva encima una capa de vidrio (material Glass) apenas más
-- grande que ella. El vidrio de Roblox refleja según el ángulo (está en su shader: mezcla el cielo
-- con 0.8 × (1 − N·V)² × fuerza): mirado de frente o hacia los pies casi no refleja, y lejos,
-- donde el piso se ve de canto, refleja mucho. Como un cristal, no un espejo. La fuerza sale de la
-- Transparency de la capa (0.5 = toda, 1 = nada). Solo llevan capa las superficies que más se ven
-- (grandes y cerca), hasta MAX_CAPAS, y se revisan de a poco para no trabar el juego.

local moduloCristal = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- CIELO Y COLORES
-- ============================================================================

local moduloCielo = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- SKINS Y WRAPS (Rivals)
-- ============================================================================

local moduloSkins = (function()
    local ARCHIVO = ruta("skins.txt")

    local function norm(texto)
        return (texto:lower():gsub("[^%w]", ""))
    end

    -- Sonidos de cada skin (tabla sacada del juego, en skins_sonidos.lua)
    local SONIDOS, ANTIGUOS = {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_sonidos.lua")))()
        SONIDOS = datos.sonidos or {}
        ANTIGUOS = datos.antiguos or {}
    end)

    -- De qué arma es cada skin y su imagen (sacado del juego, en skins_armas.lua)
    local ARMA_DE, IMAGEN_DE, WRAPS_MATERIAL, SLOT_DE = {}, {}, {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_armas.lua")))()
        ARMA_DE = datos.armas or {}
        IMAGEN_DE = datos.imagenes or {}
        WRAPS_MATERIAL = datos.wraps or {}
        SLOT_DE = datos.slots or {} -- (v6.13) arma -> Primary / Secondary / Melee / Utility
    end)

    -- Qué animación usa cada arma y skin en cada acción (Equip, Idle, Attack1, Reload...) y su
    -- velocidad (sacado del juego, en skins_animaciones.lua)
    local VISTAS, VELOCIDADES = {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_animaciones.lua")))()
        VISTAS = datos.vistas or {}
        VELOCIDADES = datos.velocidades or {}
    end)

    -- (v5.8) Skins propias, las que haces tú (no vienen del juego): skins_propias.lua. Cielo las arma con
    -- piezas y las trata como una skin más de su arma: ARMA_DE (de qué arma es), VISTAS (usa las
    -- animaciones de esa arma) y SONIDOS (los de disparo, recarga... que traiga; son archivos: "archivo:x.mp3")
    local PROPIAS = {}
    pcall(function()
        PROPIAS = loadstring(leer(ruta("skins_propias.lua")))() or {}
        for nombre, def in pairs(PROPIAS) do
            ARMA_DE[nombre] = def.arma
            VISTAS[nombre] = VISTAS[nombre] or { _arma = def.arma }
            -- (v6.20) animaciones sueltas que la skin toma de otra (las Desert Eagles: sacar, quieto y disparo de las Enerkey Pistols)
            for accion, id in pairs(def.anim or {}) do VISTAS[nombre][accion] = id end
            -- (v6.51) la "foto" de la skin propia: una miniatura dibujada con sus piezas (mini_<nombre>.png, la deja la app junto a icono.png);
            -- si no está, la del arma de la que es
            local mini = imagenPropia("mini_" .. (nombre:lower():gsub("[^%w]+", "_")) .. ".png")
            IMAGEN_DE[nombre] = (mini ~= "" and mini) or IMAGEN_DE[nombre] or IMAGEN_DE[def.arma]
            -- (v6.53) cuales son las nuestras: en la barra de armas del juego se ponen con ScaleType Fit (si no, el juego las recortaba y salian enormes)
            if mini ~= "" then
                IMAGEN_DE._propias = IMAGEN_DE._propias or {}
                IMAGEN_DE._propias[mini] = true
            end
            for accion, ids in pairs(def.sonidos or {}) do
                SONIDOS[norm(def.arma) .. "_" .. norm(nombre) .. "_" .. accion] = ids
            end
        end
    end)

    -- Los sonidos de cada animación con sus tiempos (sacado del juego, en skins_tiempos.lua): el
    -- nombre de la animación de cada acción, y qué suena en qué segundo
    local NOMBRES_ANIM, TIEMPOS = {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_tiempos.lua")))()
        NOMBRES_ANIM = datos.nombres or {}
        TIEMPOS = datos.sonidos or {}
    end)

    -- Lo demás que cada skin hace distinto (sacado del juego, en skins_efectos.lua): los sonidos de
    -- su módulo, dónde va el arma frente a la cámara, el sonido al apuntar y el color de las balas
    local MODULOS, POSICIONES, APUNTAR, TRAZADORAS = {}, {}, {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_efectos.lua")))()
        MODULOS = datos.modulos or {}
        POSICIONES = datos.posiciones or {}
        APUNTAR = datos.apuntar or {}
        TRAZADORAS = datos.trazadoras or {}
    end)

    -- (v5.8) las skins propias heredan de su arma lo que no traen: dónde va frente a la cámara, el módulo de
    -- sonidos, el sonido al apuntar y el color de las balas. Sin esto Cielo la trataría como "posición cero"
    -- y la correría respecto al arma de verdad.
    for nombre, def in pairs(PROPIAS) do
        -- (v6.31) def.imitar: va frente a la cámara como otra skin (la Desert Eagle dorada, como la Desert Eagle del Revolver)
        POSICIONES[nombre] = POSICIONES[nombre] or (def.imitar and POSICIONES[def.imitar]) or POSICIONES[def.arma]
        MODULOS[nombre] = MODULOS[nombre] or { padre = def.arma }
        -- (v6.22) el sonido de una animación que la skin toma de otra (el de sacar de las Enerkey Pistols): suena a su tiempo
        if def.nombresAnim then NOMBRES_ANIM[nombre] = setmetatable(def.nombresAnim, { __index = { _arma = def.arma } }) end
        APUNTAR[nombre] = APUNTAR[nombre] or APUNTAR[def.arma]
        TRAZADORAS[nombre] = TRAZADORAS[nombre] or TRAZADORAS[def.arma]
    end

    -- Lo que hacen algunas skins al sacarlas (de su _EquipEffect): sonidos a su tiempo, y algo que
    -- se esconde hasta el final (la hoja del Saber se enciende a los 0,4 s)
    local EQUIPAR = {
        ["Saber"] = { ocultar = "Blade", { espera = 0.4, id = 17641562119, volumen = 1.5, tono = 1 } },
        ["Cerulean Axe"] = {
            { espera = 0.55, id = 117746175185603, volumen = 0.5, tono = 0.5, azar = 0.125 },
            { espera = 0.85, id = 75313977551180, volumen = 0.875, tono = 0.9, azar = 0.2 },
            { espera = 0.85, id = 107162559513589, volumen = 0.875, tono = 0.9, azar = 0.2 },
            { espera = 0.85, id = 115716079009988, volumen = 0.875, tono = 0.9, azar = 0.2 },
        },
    }

    -- el id de la animación de una acción de un arma o skin (nil si no tiene); las skins
    -- solo traen lo que cambia respecto a su arma (_arma), y false = no la tiene
    local function animacionDe(nombre, accion)
        local v = VISTAS[nombre]
        if not v then return nil end
        local id = v[accion]
        if id == nil and v._arma and VISTAS[v._arma] then id = VISTAS[v._arma][accion] end
        return id or nil
    end

    -- el nombre de la animación de una acción (como animacionDe, pero el nombre: de él salen los sonidos)
    local function nombreAnim(nombre, accion)
        local v = NOMBRES_ANIM[nombre]
        if not v then return nil end
        local n = v[accion]
        if n == nil and v._arma and NOMBRES_ANIM[v._arma] then n = NOMBRES_ANIM[v._arma][accion] end
        return n or nil
    end

    -- si la skin no tiene una acción, la que más se le parece
    local function parecida(accion)
        if accion == "InspectRare" then return "Inspect" end
        if accion == "FinalShoot" then return "Shoot1" end
        if accion == "FinalQuickShot" then return "QuickShot" end
        return accion:match("^(.+)Empty$") or accion:match("^Empty(.+)$")
    end

    -- qué animaciones del arma de verdad se cambian por las de la skin elegida
    -- (id del juego -> id de la skin); nil si ninguna
    local function cambiosDeAnimacion(real, elegida)
        local vr = VISTAS[real]
        if not (vr and VISTAS[elegida]) then return nil end
        local acciones = {}
        for accion in pairs(vr) do acciones[accion] = true end
        for accion in pairs(vr._arma and VISTAS[vr._arma] or {}) do acciones[accion] = true end
        acciones._arma = nil
        local cambios, hay = {}, false
        for accion in pairs(acciones) do
            local deJuego, deSkin, otra = animacionDe(real, accion), animacionDe(elegida, accion), accion
            while not deSkin and otra do
                otra = parecida(otra)
                deSkin = otra and animacionDe(elegida, otra)
            end
            if deJuego and deSkin and deJuego ~= deSkin and not cambios[deJuego] then
                cambios[deJuego] = deSkin
                hay = true
            end
        end
        return hay and cambios or nil
    end

    -- el arma a la que pertenece una skin del catálogo
    local function armaDeLaSkin(s)
        return ARMA_DE[s.nombre] or (s.categoria == "Weapons" and s.nombre)
            or (VISTAS[s.nombre] and VISTAS[s.nombre]._arma) or nil
    end

    -- (v6.0) armas cuerpo a cuerpo: las que tienen ataque (Attack1) en sus animaciones (Scythe, Katana,
    -- Knife, Fists, Maul, Chainsaw, Battle Axe, Spear, Trowel, Riot Shield, Glast Shard)
    local function esCuerpoACuerpo(arma)
        local v = arma and VISTAS[arma]
        return v ~= nil and v._arma == nil and v.Attack1 ~= nil and v.Attack1 ~= false
    end

    -- ¿una skin de armaSkin se mueve y suena con SUS animaciones y sonidos sobre armaReal? Si es de la misma
    -- arma, sí; si las dos son cuerpo a cuerpo (tienen las mismas acciones: sacar, quieto, inspeccionar, correr
    -- y atacar), también: el Pirate Hook (de los puños) en la Scythe se mueve y suena como los puños
    -- (v6.13) lo mismo entre las armas de los espacios 1 y 2 (primarias y secundarias, de todo tipo): cualquiera puede
    -- llevar la skin de cualquiera, con sus animaciones y sonidos. Las de utilidad (espacio 4) no entran.
    local function esDeFuego(arma)
        local espacio = arma and SLOT_DE[arma]
        return espacio == "Primary" or espacio == "Secondary"
    end

    local function mismaFamilia(armaSkin, armaReal)
        return armaSkin ~= nil and armaReal ~= nil
            and (armaSkin == armaReal or (esCuerpoACuerpo(armaSkin) and esCuerpoACuerpo(armaReal))
                or (esDeFuego(armaSkin) and esDeFuego(armaReal)))
    end

    local biblioteca, armasBase = nil, nil
    local construirPropia -- (v5.8) arma el modelo de una skin propia; se define más abajo (necesita principalDe y enModelo)
    local catalogo, porClave, porNombre = {}, {}, {}
    local wraps, porWrap = {}, {}  -- "Nebula1" y "Nebula2" son el mismo wrap para las piezas 1 y 2
    local elecciones = {}          -- arma -> clave de la skin
    local eleccionesWrap = {}      -- arma -> nombre del wrap
    -- (v6.17) INVERTIDO: como la casilla "Inverted" del juego, que cambia de lugar las ranuras 1 y 2 del wrap
    local INV = { por = {}, copias = {} } -- por: arma -> true; copias: wrap -> su versión invertida
    function INV.de(w)
        if not w then return nil end
        local c = INV.copias[w]
        if not c then
            c = setmetatable({ invertido = true }, { __index = w })
            INV.copias[w] = c
        end
        return c
    end
    -- (v6.17) las miniaturas de los wraps son 3D de verdad (se arman solo las que se ven) y la vista grande los anima
    local MINI = { items = {}, proximo = 0, proximoVisor = 0 }
    local realesVistas = {}        -- arma -> su skin de verdad (la última vez que estuvo en la mano)
    local opacidades = {}          -- skin (su clave, o "arma:<arma>" la original) -> 0..100 (si falta, 100)
    local sonidosActivos = true

    local function guardar()
        local lineas = { "sonidos=" .. (sonidosActivos and "1" or "0") }
        for arma, clave in pairs(elecciones) do table.insert(lineas, "S|" .. arma .. "|" .. clave) end
        for arma, nombreWrap in pairs(eleccionesWrap) do table.insert(lineas, "W|" .. arma .. "|" .. nombreWrap) end
        for arma, invertido in pairs(INV.por) do
            if invertido then table.insert(lineas, "I|" .. arma .. "|1") end
        end
        for clave, valor in pairs(opacidades) do table.insert(lineas, "O|" .. clave .. "|" .. valor) end
        escribir(ARCHIVO, table.concat(lineas, "\n"))
    end

    -- la opacidad va por skin: la de la elegida, o la de tu original si no elegiste ninguna
    local function claveOpacidad(arma)
        local clave = arma and elecciones[arma]
        if clave and porClave[clave] then return clave end
        return "arma:" .. tostring(arma)
    end

    local function opacidadDe(arma)
        return opacidades[claveOpacidad(arma)] or 100
    end

    -- busca la biblioteca de skins de Rivals (al entrar al juego puede tardar un poco)
    local function prepararBiblioteca()
        local ok, b = pcall(function() return jugador.PlayerScripts.Assets.ViewModels end)
        if not (ok and b) then return false end

        table.clear(catalogo)
        table.clear(porClave)
        table.clear(porNombre)
        for _, categoria in ipairs(b:GetChildren()) do
            for _, modelo in ipairs(categoria:GetChildren()) do
                if modelo:IsA("Model") then
                    local s = {
                        clave = categoria.Name .. "/" .. modelo.Name,
                        nombre = modelo.Name, categoria = categoria.Name, modelo = modelo,
                    }
                    table.insert(catalogo, s)
                    porClave[s.clave] = s
                    porNombre[s.nombre] = porNombre[s.nombre] or s
                end
            end
        end
        -- (v5.8) las skins propias entran al catálogo como una más
        if construirPropia then
            for nombre, def in pairs(PROPIAS) do
                local ok, modelo = pcall(construirPropia, nombre, def, b)
                if ok and modelo then
                    local s = { clave = "Propias/" .. nombre, nombre = nombre, categoria = "Propias", modelo = modelo }
                    table.insert(catalogo, s)
                    porClave[s.clave] = s
                    porNombre[s.nombre] = porNombre[s.nombre] or s
                elseif not ok then
                    warn("[Cielo] skin propia " .. nombre .. ": " .. tostring(modelo))
                end
            end
        end
        table.sort(catalogo, function(x, y) return x.nombre:lower() < y.nombre:lower() end)

        table.clear(wraps)
        table.clear(porWrap)
        local carpetaWraps = b.Parent:FindFirstChild("WrapTextures")
        if carpetaWraps then
            for _, carpeta in ipairs(carpetaWraps:GetChildren()) do
                if carpeta.Name ~= "MISSING_WRAP" then
                    local base, n = carpeta.Name:match("^(.-)_?(%d)$")
                    if not base or base == "" then
                        base, n = carpeta.Name, "0"
                    end
                    local w = porWrap[base]
                    if not w then
                        w = { nombre = base, texto = (base:gsub("_", " ")), variantes = {} }
                        porWrap[base] = w
                        table.insert(wraps, w)
                    end
                    w.variantes[tonumber(n)] = carpeta
                end
            end
        end
        -- (v5.7) los wraps de puro material (Glass, Black Glass, Gold, Chrome...) no tienen carpeta de
        -- texturas: son material, color, transparencia y reflejo por ranura (skins_armas.lua)
        -- (v6.13) los que SÍ tienen carpeta de texturas (Ice Queen, Soul Scourge...) traen además material, color,
        -- transparencia y reflejo por ranura: antes se ponía solo el dibujo y por eso no se parecían a los del juego
        for nombre, datos in pairs(WRAPS_MATERIAL) do
            local clave = nombre:gsub(" ", "_")
            local conTextura = datos.tex and porWrap[datos.tex]
            if conTextura then
                conTextura.ranuras = datos.ranuras
            elseif not porWrap[clave] then
                local w = { nombre = clave, texto = nombre, variantes = {}, ranuras = datos.ranuras, material = true }
                porWrap[clave] = w
                table.insert(wraps, w)
            end
        end
        table.sort(wraps, function(x, y) return x.nombre:lower() < y.nombre:lower() end)

        -- lo elegido (se guarda entre partidas)
        pcall(function()
            for linea in readfile(ARCHIVO):gmatch("[^\r\n]+") do
                local tipo, arma, valor = linea:match("^(%a)|(.-)|(.+)$")
                if tipo == "S" and porClave[valor] then
                    elecciones[arma] = valor
                elseif tipo == "S" and valor == "Cielo/Invisible" then
                    -- la skin Invisible de la v3.4 queda como la original al 0%
                    opacidades["arma:" .. arma] = opacidades["arma:" .. arma] or 0
                elseif tipo == "W" and porWrap[valor] then
                    eleccionesWrap[arma] = valor
                elseif tipo == "I" then
                    INV.por[arma] = valor == "1" or nil
                elseif tipo == "O" and tonumber(valor) then
                    opacidades[arma] = math.clamp(math.floor(tonumber(valor) + 0.5), 0, 100)
                elseif linea == "sonidos=0" then
                    sonidosActivos = false
                else
                    local a, clave = linea:match("^(.-)=(.+)$") -- formato de la v1
                    if a and porClave[clave] then elecciones[a] = clave end
                end
            end
        end)

        armasBase = b:FindFirstChild("Weapons")
        biblioteca = b
        return true
    end

    local function variante(w, grupo)
        if w.variantes[grupo] then return w.variantes[grupo] end
        if w.variantes[1] then return w.variantes[1] end
        if w.variantes[0] then return w.variantes[0] end
        for _, carpeta in pairs(w.variantes) do return carpeta end
        return nil
    end

    -- las capas de dibujo de un wrap (para la muestra de la lista)
    local function capasDe(w)
        if w.capas then return w.capas end
        local capas, vistas = {}, {}
        local carpeta = variante(w, 1)
        if carpeta then
            for _, t in ipairs(carpeta:GetChildren()) do
                if t:IsA("Decal") then -- Texture también es Decal
                    local clave = t.Texture .. "|" .. tostring(t.Color3) .. "|" .. tostring(t.Transparency)
                    if not vistas[clave] then
                        vistas[clave] = true
                        table.insert(capas, {
                            imagen = t.Texture, color = t.Color3, transparencia = t.Transparency, z = t.ZIndex,
                            baldosa = t:IsA("Texture") and Vector2.new(t.StudsPerTileU, t.StudsPerTileV) or nil,
                        })
                    end
                end
            end
        end
        table.sort(capas, function(a, b) return a.z < b.z end)
        w.capas = capas
        return capas
    end

    -- cada pieza (Body, Magazine...) trae dónde va en la mano (atributo C0); sirve para
    -- adivinar el arma de una skin que no esté en skins_armas.lua (por ej. si el juego agrega skins)
    local function firma(s)
        if s.firma then return s.firma end
        local t = {}
        for _, pieza in ipairs(s.modelo:GetChildren()) do
            if pieza:IsA("Model") then
                local c0 = pieza:GetAttribute("C0")
                if typeof(c0) == "CFrame" then t[pieza.Name] = c0.Position end
            end
        end
        s.firma = t
        return t
    end

    local compatiblesCache = {}
    local function compatibles(arma)
        if compatiblesCache[arma] then return compatiblesCache[arma] end
        local lista = {}
        local base = armasBase and armasBase:FindFirstChild(arma)
        local fb = base and firma({ modelo = base }) or {}
        for _, s in ipairs(catalogo) do
            local suya = ARMA_DE[s.nombre]
            local entra
            if s.categoria == "Weapons" then
                entra = s.nombre == arma
            elseif suya then
                entra = suya == arma
            else
                local fs = firma(s)
                local comunes, calza = 0, true
                for pieza, posicion in pairs(fb) do
                    local otra = fs[pieza]
                    if otra then
                        comunes = comunes + 1
                        if (otra - posicion).Magnitude > 0.01 then
                            calza = false
                            break
                        end
                    end
                end
                entra = (calza and comunes > 1) or s.nombre:find(arma, 1, true) ~= nil
            end
            if entra then table.insert(lista, s) end
        end
        compatiblesCache[arma] = lista
        return lista
    end

    -- Poner y quitar skins y wraps ---------------------------------------------

    -- "<jugador> - <arma> - <skin de verdad>"
    local function armaDe(vm)
        local _, arma, skinReal = vm.Name:match("^(.-) %- (.-) %- (.+)$")
        return arma, skinReal
    end

    local function principalDe(pieza)
        return pieza:FindFirstChild(pieza.Name .. "Primary") or pieza:FindFirstChild("Primary")
    end

    local function enLlavero(obj, raiz)
        local a = obj.Parent
        while a and a ~= raiz do
            if a.Name == "_charm_attachment_model" then return true end
            a = a.Parent
        end
        return false
    end

    local EFECTOS = { "ParticleEmitter", "Beam", "Trail", "PointLight", "SpotLight", "SurfaceLight", "Fire", "Smoke", "Sparkles" }
    local function esEfecto(x)
        for _, clase in ipairs(EFECTOS) do
            if x:IsA(clase) then return true end
        end
        return false
    end

    local DIMINUTO = Vector3.new(0.001, 0.001, 0.001) -- tamaño con que se esconde el arma de verdad

    -- En los puños (y sus guantes) las piezas no van en ItemVisual: "_left_arm" y "_right_arm"
    -- van dentro del brazo, con su principal justo encima de él. "_fake" son brazos de mentira
    -- que solo usa la vista del menú.
    local BRAZOS = { _left_arm = "LeftArm", _right_arm = "RightArm" }

    -- dónde va una pieza en reposo respecto a la raíz del arma (atributos C0 y C1)
    local function reposo(pieza)
        local c0, c1 = pieza:GetAttribute("C0"), pieza:GetAttribute("C1")
        if typeof(c0) ~= "CFrame" then return nil end
        return c0 * (typeof(c1) == "CFrame" and c1:Inverse() or CFrame.new())
    end

    -- "Bullets3" -> "Bullets"
    local function nombreBase(n)
        return (n:gsub("[%s_]*%d+$", ""))
    end

    -- la pieza del arma de verdad que sigue una pieza de la skin: la del mismo nombre, la del
    -- mismo nombre sin el número (Bullets3 -> Bullets), una que lo contenga, o el cuerpo
    local function anclaPara(n, vivas)
        if vivas[n] then return vivas[n] end
        local base = nombreBase(n)
        for otro, p in pairs(vivas) do
            if nombreBase(otro) == base then return p end
        end
        local mejor, largo = nil, 0
        for otro, p in pairs(vivas) do
            local bn = nombreBase(otro)
            if #bn > largo and (base:find(bn, 1, true) or bn:find(base, 1, true)) then
                mejor, largo = p, #bn
            end
        end
        return mejor or vivas.Body
    end

    -- Cómo se ve armada cada skin: en la biblioteca las piezas están puestas en su lugar.
    -- Los C0 no sirven para eso: cada skin los anota a su manera y su propia animación lo
    -- corrige (las balas del revólver normal, por ejemplo, tienen el C0 corrido hacia un lado).
    local function enModelo(modelo, pieza)
        local cuerpo = modelo:FindFirstChild("Body")
        local pc = cuerpo and principalDe(cuerpo)
        local pp = pieza and principalDe(pieza)
        if not (pc and pp) then return nil end
        return pc.CFrame:ToObjectSpace(pp.CFrame)
    end

    -- una pieza que solo sale en una animación ("ReloadBullets3") termina donde está su
    -- gemela de siempre ("Bullets3"): se ubica con esa
    local function gemela(modelo, pieza)
        if pieza and pieza:GetAttribute("AnimationContexts") then
            local nombre = pieza.Name:gsub("^Reload", "")
            local otra = nombre ~= pieza.Name and modelo:FindFirstChild(nombre)
            if otra and otra:IsA("Model") and not otra:GetAttribute("AnimationContexts") then return otra end
        end
        return pieza
    end

    -- (v5.8) El modelo de una skin propia: piezas (Model) con su Primary y sus partes, como las de la
    -- biblioteca. La Primary de cada pieza va donde la del arma de verdad cuando está armada (así Cielo la
    -- pega igual que a cualquier skin de esa arma) y las partes van respecto a su Primary.
    construirPropia = function(nombre, def, vms)
        local pesos = vms:FindFirstChild("Weapons")
        local armaLib = pesos and pesos:FindFirstChild(def.arma)
        -- (v6.20) si la biblioteca no tiene el arma (las Energy Pistols no aparecían), se arma igual con las piezas de la lista
        local modelo = Instance.new("Model")
        modelo.Name = nombre
        for nombrePieza, partes in pairs(def.piezas) do
            if type(partes) == "string" then partes = def.piezas[partes] end -- "LeftBody" = la misma lista que "RightBody"
            local real = armaLib and armaLib:FindFirstChild(nombrePieza)
            -- (v6.1) las piezas de los brazos (_left_arm, _right_arm) van dentro del brazo y no tienen por qué estar en el arma base
            local esBrazo = BRAZOS[nombrePieza] ~= nil
            -- (v6.31) def.c0 = piezas con su propio C0 (la Desert Eagle dorada del Revolver trae Body y Slide como la skin del juego:
            -- sus animaciones están hechas para esas uniones); entran aunque el arma de verdad no tenga la pieza
            local c0Propio = def.c0 and def.c0[nombrePieza]
            if real or esBrazo or not armaLib or c0Propio then
                local pieza = Instance.new("Model")
                pieza.Name = nombrePieza
                for _, atributo in ipairs({ "C0", "C1", "AnimationContexts" }) do
                    local v = real and real:GetAttribute(atributo)
                    if v ~= nil then pieza:SetAttribute(atributo, v) end
                end
                if c0Propio then
                    pieza:SetAttribute("C0", CFrame.new(c0Propio[1], c0Propio[2], c0Propio[3]))
                    pieza:SetAttribute("C1", CFrame.new())
                end
                -- (v6.36) def.ctx: piezas que solo salen en una animación (el cargador nuevo de la recarga: "Reload")
                local ctxPropio = def.ctx and def.ctx[nombrePieza]
                if ctxPropio then pieza:SetAttribute("AnimationContexts", ctxPropio) end
                local enCuerpo = (not esBrazo and real and nombrePieza ~= "Body") and enModelo(armaLib, real) or CFrame.new()
                -- (v6.20) las armas sin "Body" (las dos Energy Pistols) traen dónde va cada pieza en la vista previa
                local sitio = def.sitios and def.sitios[nombrePieza]
                if sitio then enCuerpo = CFrame.new(sitio[1], sitio[2], sitio[3]) end
                local primaria = crear("Part", {
                    Name = "Primary", Size = esBrazo and Vector3.new(1.8, 0.45, 0.45) or Vector3.new(0.25, 0.25, 0.25),
                    Transparency = 1, Anchored = true,
                    CanCollide = false, CanQuery = false, CanTouch = false, CFrame = enCuerpo or CFrame.new(),
                    Parent = pieza,
                })
                for _, d in ipairs(partes) do
                    local lugar = CFrame.new(d.pos[1], d.pos[2], d.pos[3])
                        * CFrame.Angles(math.rad(d.rot[1]), math.rad(d.rot[2]), math.rad(d.rot[3]))
                    local parte = Instance.new("Part")
                    parte.Name = d.n
                    if d.f == "cilindro" then
                        -- el largo de un cilindro de Roblox va en X: se gira para que quede a lo largo de Z
                        parte.Shape = Enum.PartType.Cylinder
                        parte.Size = Vector3.new(d.size[3], d.size[1], d.size[2])
                        lugar = lugar * CFrame.Angles(0, math.pi / 2, 0)
                    else
                        parte.Size = Vector3.new(d.size[1], d.size[2], d.size[3])
                    end
                    local ok, material = pcall(function() return Enum.Material[d.mat] end)
                    parte.Material = ok and material or Enum.Material.SmoothPlastic
                    parte.Color = Color3.fromRGB(d.color[1], d.color[2], d.color[3])
                    if d.tr then parte.Transparency = d.tr end -- (v6.59) vidrio: partes translucidas (la hoja de la Terrambit)
                    -- (v6.4) el metal con reflejo propio: sin él, según la luz del mapa se ve como plástico gris
                    if d.rf then
                        parte.Reflectance = d.rf
                    elseif d.mat == "Metal" then
                        parte.Reflectance = d.g and 0.22 or 0.15
                    end
                    -- (v6.20) el material de oro del juego: una variante de MaterialService ("Liquid Gold"); si no está, queda el metal con reflejo
                    if d.mv then
                        local ok, variante = pcall(function() return game:GetService("MaterialService"):FindFirstChild(d.mv, true) end)
                        if ok and variante and variante:IsA("MaterialVariant") then
                            parte.Material = variante.BaseMaterial
                            parte.MaterialVariant = d.mv
                        end
                    end
                    parte.Anchored, parte.CanCollide, parte.CanQuery, parte.CanTouch = true, false, false, false
                    parte.Massless = true
                    parte.TopSurface, parte.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
                    if d.wg then parte:SetAttribute("WrapGroup", d.wg) end -- (wg=false: detalle chico, no recibe wraps)
                    -- (v6.1) parte de una garra: crece desde su origen (la base de su cuchilla) al salir las garras
                    if d.g and d.o then parte:SetAttribute("GarraOrigen", Vector3.new(d.o[1], d.o[2], d.o[3])) end
                    parte.CFrame = primaria.CFrame * lugar
                    parte.Parent = pieza
                end
                pieza.PrimaryPart = primaria
                pieza.Parent = modelo
            end
        end
        return modelo
    end

    -- (v6.15) WRAPS ANIMADOS. El juego anima cada wrap con un módulo propio (WrapGroupObjects.<nombre>) que cada cuadro mueve
    -- las texturas del wrap. Lo que hace cada uno está rehecho en wraps_animados.lua (los 30): aquí queda el motor.
    local WRAPANIM = { fn = {}, proximo = 0, colorUnico = {} }
    pcall(function() loadstring(leer(ruta("wraps_animados.lua")))()(WRAPANIM) end)

    -- el wrap de puro material sobre una parte: la ranura es el grupo de la pieza (atributo WrapGroup).
    -- antes: si viene, ahí se anota cómo era la pieza para devolverla (las piezas de verdad); en las
    -- copias no hace falta, y solo ahí se cambia la transparencia (el juego maneja la de las de verdad)
    local function materialEn(parte, wrap, grupo, antes)
        local ranura = grupo and wrap.ranuras[grupo]
        if grupo and ranura == nil then ranura = wrap.ranuras[1] end -- (false = esa ranura no cambia nada)
        if not ranura then return end
        if antes and not antes[parte] then
            antes[parte] = { parte.Material, parte.Color, parte.Reflectance, parte.MaterialVariant }
        end
        if ranura.m then
            local ok, material = pcall(function() return Enum.Material[ranura.m] end)
            if ok and material then
                parte.Material = material
                parte.MaterialVariant = ""
            end
        elseif ranura.mv then
            -- un MaterialVariant por nombre (Glacier, Developore, Pine...): vive en MaterialService con su material base
            local ok, variante = pcall(function() return game:GetService("MaterialService"):FindFirstChild(ranura.mv) end)
            if ok and variante and variante:IsA("MaterialVariant") then
                parte.Material = variante.BaseMaterial
                parte.MaterialVariant = ranura.mv
            end
        end
        if ranura.c then parte.Color = Color3.fromRGB(ranura.c[1], ranura.c[2], ranura.c[3]) end
        local unico = ranura.obj and WRAPANIM.colorUnico[ranura.obj]
        if unico then parte.Color = unico(parte.Color) end -- Pixel Blight (más brillante), Fish Scales (tono del día)
        if ranura.r then parte.Reflectance = math.clamp(ranura.r, 0, 1) end
        if ranura.t and not antes and parte.Transparency < 0.99 then
            parte.Transparency = math.max(parte.Transparency, ranura.t)
        end
    end

    -- el dibujo del wrap sobre una parte, según su grupo (atributo WrapGroup)
    local function ponerWrapEn(parte, wrap, anotar, antes)
        local grupo = parte:GetAttribute("WrapGroup")
        if wrap.invertido and grupo then grupo = (grupo == 1 and 2) or (grupo == 2 and 1) or grupo end
        local carpetaWrap, usada
        if wrap.ranuras then
            pcall(materialEn, parte, wrap, grupo, antes)
            usada = grupo and wrap.ranuras[grupo]
            if grupo and usada == nil then usada = wrap.ranuras[1] end
            -- (v6.15) las piezas con wrap animado se anotan (Pearlescent y Dutchman les cambian el color)
            if anotar and usada and usada.obj then anotar(parte, usada.obj, true) end
            if wrap.material then return end
            -- con dibujo: solo las ranuras que traen textura (Ice Queen: la 1; las otras llevan solo material y color)
            if not (usada and usada.tex) then return end
            carpetaWrap = wrap.variantes[tonumber(usada.tex:match("(%d)$")) or 0] or variante(wrap, grupo)
        else
            carpetaWrap = grupo and variante(wrap, grupo)
        end
        if not carpetaWrap then return end
        for _, t in ipairs(carpetaWrap:GetChildren()) do
            -- (v6.16) los wraps con brillo (Accretion, Limefire) traen ParticleEmitter en su carpeta: se copian también
            if t:IsA("Decal") or (anotar and t:IsA("ParticleEmitter")) then
                local copia = t:Clone()
                copia.Parent = parte
                if anotar then anotar(copia, usada and usada.obj, false) end
            end
        end
    end

    -- El juego muestra y esconde piezas con LocalTransparencyModifier (el cargador de la
    -- recarga...) o con Transparency. Cada copia hace lo mismo que su pieza de verdad: se mira
    -- la principal de la pieza y una de sus partes visibles (el "testigo"). Lo que va pegado a
    -- un brazo (los guantes) hace lo mismo que el brazo.
    local function guiaVisible(g)
        local guia = g.guia
        if not (guia and guia.Parent) then return false end
        local p = guia:IsA("BasePart") and guia or principalDe(guia) or guia:FindFirstChildWhichIsA("BasePart", true)
        if not (p and p:IsDescendantOf(workspace)) then return false end
        if p.LocalTransparencyModifier >= 0.99 then return false end
        local t = g.testigo
        return not (t and (t.Transparency >= 0.99 or t.LocalTransparencyModifier >= 0.99))
    end

    -- Visible, cada copia va con la opacidad elegida (g.r.opacidad, de 0 a 1); sus efectos
    -- (brillos, partículas) solo se apagan del todo en 0%.
    local function aplicarVisibilidad(g)
        local v = guiaVisible(g) and 1 - g.r.opacidad or 1
        if v == g.v then return end
        g.v = v
        -- (v6.10) las garras no están en g.cosas: prepararGarras mira esto (por mano) y manda el soporte lejos si v >= 1
        g.r.garrasV = g.r.garrasV or {}
        if g.guia then g.r.garrasV[g.guia.Name] = v end
        for _, x in ipairs(g.cosas) do
            pcall(function() x.LocalTransparencyModifier = v end)
        end
        for efecto, activo in pairs(g.efectos) do
            pcall(function() efecto.Enabled = activo and v < 1 end)
        end
    end

    -- El llavero cuelga fuera del arma (un modelo al lado de ItemVisual) y no se copia: su
    -- LocalTransparencyModifier queda en lo que quiere el juego (e.juego) con la opacidad encima.
    local function atenuar(r, parte)
        local e = r.llavero[parte]
        -- (v5.4) con una skin elegida en Cielo el llavero no va (es el de tu arma de verdad)
        local deseado = r.clave and 1 or (1 - (1 - e.juego) * r.opacidad)
        if math.abs(parte.LocalTransparencyModifier - deseado) > 0.0005 then
            e.puesto = deseado
            parte.LocalTransparencyModifier = deseado
        end
    end

    local function cambiarOpacidad(r, opacidad)
        r.opacidad = opacidad
        for _, g in ipairs(r.grupos) do aplicarVisibilidad(g) end
        for parte in pairs(r.llavero) do pcall(atenuar, r, parte) end
    end

    local registro = setmetatable({}, { __mode = "k" }) -- arma en la mano -> lo que le hicimos

    -- Skins con animaciones propias (la Karambit, el Keyvolver...). Cada animación del juego que
    -- la skin cambia sigue sonando, porque el juego engancha a sus fotogramas los sonidos y los
    -- efectos, pero casi sin peso. Encima suena la de la skin, con el peso, la prioridad y la
    -- velocidad que le da el juego a la suya.
    local ESCONDIDA = 0.001 -- el peso que le queda a la del juego
    local propias = setmetatable({}, { __mode = "k" }) -- nuestras pistas (a esas no se les hace nada)
    local prepararTiempos = function() end -- (más abajo, en Sonidos) los sonidos de la skin a su tiempo

    local function soltarAnimaciones(r)
        local a = r.anim
        if not a then return end
        r.anim = nil
        for g, par in pairs(a.pares) do
            pcall(function()
                if par.activo and g.IsPlaying then g:AdjustWeight(par.peso or 1, 0.1) end
            end)
        end
        for _, pista in pairs(a.pistas) do
            pcall(function() pista:Stop(0.1) end)
            task.delay(0.2, function() pcall(function() pista:Destroy() end) end)
        end
    end

    local function prepararAnimaciones(r, vm, cambios)
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        if not animator then return end
        local a = { pares = {}, pistas = {} }
        r.anim = a
        local function pista(id)
            local p = a.pistas[id]
            if not p then
                local animacion = Instance.new("Animation")
                animacion.AnimationId = "rbxassetid://" .. id
                p = animator:LoadAnimation(animacion)
                propias[p] = true
                a.pistas[id] = p
            end
            return p
        end
        for _, id in pairs(cambios) do pcall(pista, id) end -- se cargan de entrada, para que estén listas

        local function alSonar(g)
            if propias[g] or r.anim ~= a then return end
            -- una acción nueva corta lo nuestro que había quedado sonando después de la suya
            for _, par in pairs(a.pares) do
                if par.demas then
                    par.demas = false
                    par.nuestra:Stop(0.15)
                end
            end
            local idJuego = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            local idSkin = idJuego and cambios[idJuego]
            if not idSkin then return end
            local par = a.pares[g]
            if not par then
                par = { nuestra = pista(idSkin), factor = (VELOCIDADES[idSkin] or 1) / (VELOCIDADES[idJuego] or 1) }
                a.pares[g] = par
                table.insert(r.conexiones, g.Stopped:Connect(function()
                    if not par.activo then return end
                    par.activo = false
                    local nuestra = par.nuestra
                    -- si la del juego terminó sola, la de la skin (si dura más) sigue hasta su final
                    if not g.Looped and g.Length > 0 and g.TimePosition >= g.Length - 0.06
                        and not nuestra.Looped and nuestra.IsPlaying then
                        par.demas = true
                    else
                        nuestra:Stop(0.15)
                    end
                end))
            end
            local nuestra = par.nuestra
            par.activo, par.demas = true, false
            par.peso = g.WeightTarget > ESCONDIDA * 2 and g.WeightTarget or (par.peso or 1)
            par.velocidad, par.puesto = g.Speed, ESCONDIDA
            nuestra.Priority = g.Priority
            nuestra.Looped = g.Looped
            nuestra:Play(0.1, par.peso, g.Speed * par.factor)
            -- si la del juego ya iba avanzada (la skin se puso a mitad), la nuestra parte igual
            if g.TimePosition > 0.05 and g.Length > 0 and nuestra.Length > 0 then
                nuestra.TimePosition = math.min(g.TimePosition / g.Length * nuestra.Length, nuestra.Length - 0.05)
            end
            g:AdjustWeight(ESCONDIDA, 0)
        end
        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g) pcall(alSonar, g) end))
        for _, g in ipairs(animator:GetPlayingAnimationTracks()) do pcall(alSonar, g) end
    end

    -- (v6.1) GARRAS DE WOLVERINE: animaciones propias para los brazos. Las armas cuerpo a cuerpo animan solo dos
    -- huesos (RightArm y LeftArm). Cuando el juego pone su Equip / Attack1 / Attack2 / Inspect, corre la nuestra:
    -- cada mano se coloca en un punto (x, y, z) con las garras apuntando hacia una dirección (giro, arriba) y un
    -- roll, y de ahí sale el Transform del Motor6D del brazo (la misma matemática que el editor de garras). Lo
    -- demás (quieto, correr) lo sigue haciendo el juego. Las garras salen y se guardan estirando sus cuchillas (e).
    local tocarArchivo = function() end -- (más abajo, en Sonidos)
    local GARRAS = { -- (una sola variable local para no gastar las que quedan en este módulo)
        ease = {
            lin = function(u) return u end,
            suave = function(u) return u * u * (3 - 2 * u) end,
            acel = function(u) return u * u end,
            desacel = function(u) return 1 - (1 - u) * (1 - u) end,
        },
        campos = { "x", "y", "z", "yaw", "pitch", "roll", "e" },
    }

    -- (v6.6) el registro (garras_log.txt); ventana = hasta cuándo se anotan también los sonidos nuevos del juego
    GARRAS.lineas, GARRAS.assets = {}, {}
    function GARRAS.anotar(texto)
        table.insert(GARRAS.lineas, string.format("%7.2f  %s", os.clock() % 10000, texto))
        if #GARRAS.lineas > 120 then table.remove(GARRAS.lineas, 1) end
        -- (v6.7) el archivo se escribe como mucho cada 2 s: escribirlo en cada línea daba tirones
        if not GARRAS.pendiente then
            GARRAS.pendiente = true
            task.delay(2, function()
                GARRAS.pendiente = false
                escribir(ruta("garras_log.txt"), table.concat(GARRAS.lineas, "\n"))
            end)
        end
    end

    -- (v6.12) mide un tramo: si tardó más de 50 ms se anota en el registro (para encontrar qué congela el juego)
    function GARRAS.tarde(nombre, desde)
        local dt = os.clock() - desde
        if dt > 0.05 then GARRAS.anotar(string.format("LENTO %s: %.0f ms", nombre, dt * 1000)) end
    end

    function GARRAS.poseEn(kf, t)
        local n = #kf
        if t <= kf[1].t then return kf[1].D, kf[1].I end
        if t >= kf[n].t then return kf[n].D, kf[n].I end
        local i = 1
        while i < n - 1 and kf[i + 1].t <= t do i = i + 1 end
        local a, b = kf[i], kf[i + 1]
        local u = (GARRAS.ease[b.ease] or GARRAS.ease.lin)((t - a.t) / (b.t - a.t))
        local function mezcla(p, q)
            local res = {}
            for _, c in ipairs(GARRAS.campos) do res[c] = p[c] + (q[c] - p[c]) * u end
            return res
        end
        return mezcla(a.D, b.D), mezcla(a.I, b.I)
    end

    -- el CFrame del brazo en la raíz para una mano en (x, y, z) con las garras hacia (giro, arriba) y un roll
    function GARRAS.brazoDeMano(p, rollBase, mano)
        local yaw, pitch = math.rad(p.yaw), math.rad(p.pitch)
        local D = Vector3.new(math.sin(yaw) * math.cos(pitch), math.sin(pitch), -math.cos(yaw) * math.cos(pitch))
        local X = -D
        local Y0 = Vector3.new(0, 1, 0) - X * X.Y
        if Y0.Magnitude < 1e-3 then Y0 = Vector3.new(0, 0, 1) - X * X.Z end
        Y0 = Y0.Unit
        local Z0 = X:Cross(Y0)
        local r = math.rad(p.roll + rollBase)
        local Y = Y0 * math.cos(r) + Z0 * math.sin(r)
        local Z = Z0 * math.cos(r) - Y0 * math.sin(r)
        return CFrame.fromMatrix(Vector3.new(p.x, p.y, p.z) + D * mano, X, Y, Z)
    end

    local function prepararGarras(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local acciones, gp = def and def.acciones, def and def.garras
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        local raiz = vm:FindFirstChild("HumanoidRootPart")
        if not (acciones and gp and animator and raiz and r.carpeta) then return end
        local motores = { RightArm = raiz:FindFirstChild("RightArm"), LeftArm = raiz:FindFirstChild("LeftArm") }
        if not (motores.RightArm and motores.LeftArm) then return end

        -- (v6.8) las garras salen DESLIZÁNDOSE, enteras y con todo su detalle (antes cada parte crecía de tamaño): las
        -- cuchillas están guardadas dentro de la mano, hacia atrás por su propio eje, y al salir se tiran hacia adelante.
        -- Todas las partes de una mano cuelgan de un soporte que se mueve (2 escrituras por cuadro, no 128); las que aún
        -- están detrás del frente de la mano se ocultan (Transparency) para que no asomen por el brazo.
        local cuchillas, soportes = {}, {}
        local inclina = math.rad(gp.inclina or 0)
        local frente = gp.mano - 0.05 -- X (en el sistema del brazo) desde donde se ven las cuchillas
        local minX = 0
        for _, d in ipairs(r.carpeta:GetDescendants()) do
            local origen = d:IsA("BasePart") and d:GetAttribute("GarraOrigen")
            local weld = origen and d:FindFirstChildOfClass("Weld")
            if origen and weld and weld.Part0 then
                local lado = weld.Part0.Name
                if not soportes[lado] then
                    local soporte = Instance.new("Part")
                    soporte.Name = "CieloGarrasSoporte"
                    soporte.Size = Vector3.new(0.05, 0.05, 0.05)
                    soporte.Transparency = 1
                    soporte.Massless = true
                    soporte.CanCollide, soporte.CanQuery, soporte.CanTouch = false, false, false
                    soporte.CFrame = weld.Part0.CFrame
                    soporte.Parent = r.carpeta
                    local unionSoporte = Instance.new("Weld")
                    unionSoporte.Part0, unionSoporte.Part1 = weld.Part0, soporte
                    unionSoporte.Parent = soporte
                    soportes[lado] = unionSoporte
                end
                weld.Part0 = soportes[lado].Part1 -- ahora cuelga del soporte (que está en el mismo lugar que el brazo)
                local x = weld.C0.Position.X
                if x < minX then minX = x end
                table.insert(cuchillas, { parte = d, lado = lado, x0 = x })
            end
        end
        -- cuánto hay que tirar para que hasta la punta quede detrás del frente de la mano
        local recorrido = (frente - minX) / math.max(math.cos(inclina), 0.2) + 0.02
        local ext = { RightArm = 0, LeftArm = 0 } -- cuánto salieron las garras de cada mano (0 a 1)
        local puesto = {} -- la última e puesta en cada mano
        -- (v6.9) guardadas = el soporte se manda MUY lejos (nada que dibujar, sin cambiar la transparencia de 128 partes, que
        -- daba un tirón al sacarlas); al salir se desliza desde dentro de la mano
        local function ponerGarras()
            for lado, union in pairs(soportes) do
                local e = math.floor(math.clamp(ext[lado] or 0, 0, 1) * 60 + 0.5) / 60
                if r.garrasV and (r.garrasV[lado] or 0) >= 0.99 then e = 0 end -- el juego tiene escondida la mano
                if puesto[lado] ~= e then
                    puesto[lado] = e
                    if e <= 0 then
                        union.C0 = CFrame.new(0, -3000, 0)
                    else
                        local s = (1 - e) * recorrido -- cuánto siguen metidas, a lo largo de su eje (hacia atrás e inclinadas)
                        union.C0 = CFrame.new(s * math.cos(inclina), s * math.sin(inclina), 0)
                    end
                end
            end
        end

        -- (v6.3) un registro de lo que pasa, para saber qué ve el script si algo no funciona (garras_log.txt)
        local anotar = GARRAS.anotar

        -- qué animación del juego es cada acción nuestra: se miran las animaciones de TODAS las skins de esa
        -- arma (no solo la de verdad), por si el juego usa la de otra; y como respaldo, por el nombre
        local mapa = {}
        local familia = {}
        for nombre, v in pairs(VISTAS) do
            if nombre == armaReal or v._arma == armaReal then table.insert(familia, nombre) end
        end
        for _, nombre in ipairs(familia) do
            for _, accion in ipairs({ "Equip", "Attack1", "Attack2", "Inspect", "InspectRare" }) do
                local idJuego = animacionDe(nombre, accion)
                local nuestra = accion == "InspectRare" and "Inspect" or accion
                if idJuego and acciones[nuestra] then mapa[idJuego] = nuestra end
            end
        end
        local function accionDe(g)
            local idJuego = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            local accion = idJuego and mapa[idJuego]
            if accion then return accion end
            local nombre = string.lower(g.Name or "")
            if nombre:find("inspect") and acciones.Inspect then return "Inspect" end
            if nombre:find("equip") and acciones.Equip then return "Equip" end
            return nil
        end

        local activa = nil -- la acción nuestra que está corriendo: { nombre, inicio, len, kf }
        local listoEn = os.clock() + 0.25 -- los primeros instantes las garras siguen guardadas, por si empieza el Equip
        local rollBase = gp.rollBase

        local function empezar(accion)
            local a = acciones[accion]
            -- el juego avisa dos veces de la misma acción (dos pistas): la segunda no la reinicia
            if activa and activa.nombre == accion and os.clock() - activa.inicio < 0.25 then return end
            local mia = { nombre = accion, inicio = os.clock(), len = a.len, kf = a.kf }
            activa = mia
            anotar("empieza " .. accion .. " (" .. a.len .. " s)")
            -- sonidos a su tiempo: el snikt al salir las garras (Equip) y un raspón en cada pasada de la inspección
            local sonidos = def.sonidos or {}
            local function sonarEn(s, cuando)
                task.delay(cuando, function()
                    -- (si el juego se atrasó y la acción ya terminó, el sonido igual suena: se avisa tarde, no sobra)
                    if (activa == mia or os.clock() - mia.inicio < 3) and vivo and registro[vm] == r and sonidosActivos then
                        local bien, fallo = pcall(tocarArchivo, { s.archivo }, { Volume = s.vol or 1, PlaybackSpeed = s.tono or 1 })
                        anotar(string.format("suena %s (vol %s): %s", tostring(s.archivo), tostring(s.vol), bien and "ok" or tostring(fallo)))
                    else
                        anotar(string.format("NO suena %s: activa=%s vivo=%s registro=%s sonidos=%s", tostring(s.archivo),
                            tostring(activa == mia), tostring(vivo), tostring(registro[vm] == r), tostring(sonidosActivos)))
                    end
                end)
            end
            if accion == "Equip" and sonidos.snikt then
                sonarEn(sonidos.snikt, sonidos.snikt.t or 0.4)
            elseif accion == "Inspect" and sonidos.afilar then
                for _, cuando in ipairs(sonidos.afilar.ts or {}) do sonarEn(sonidos.afilar, cuando) end
            end
        end

        local vistas = setmetatable({}, { __mode = "k" }) -- las pistas que ya se miraron
        local function alSonar(g, sondeo)
            if propias[g] or (sondeo and vistas[g]) then return end
            vistas[g] = true
            local accion = accionDe(g)
            anotar(string.format("pista %s id=%s dura=%.2f -> %s", tostring(g.Name),
                tostring(g.Animation and g.Animation.AnimationId), g.Length or -1, tostring(accion)))
            if not accion then return end
            empezar(accion)
            pcall(function() g:AdjustWeight(ESCONDIDA, 0) end)
        end

        -- por si el juego pone sus animaciones en otro Animator o AnimationPlayed no avisa: se mira cada tanto
        local animadores, proximoBarrido, proximaBusqueda = { animator }, 0, 5 + os.clock()
        local function barrer(ahora)
            if ahora < proximoBarrido then return end
            proximoBarrido = ahora + 1
            for g in pairs(vistas) do
                if not g.IsPlaying then vistas[g] = nil end -- si la vuelven a poner, cuenta otra vez
            end
            for _, a in ipairs(animadores) do
                for _, g in ipairs(a:GetPlayingAnimationTracks()) do pcall(alSonar, g, true) end
            end
        end

        -- El animador del juego escribe los Transform entre PreAnimation y Stepped (lo midió el registro de v6.6): se
        -- escribe después de eso, en Stepped y Heartbeat (y otra vez antes de dibujar, por si acaso)
        local ultimoHB, gastoPoner = nil, 0
        local function actualizar(origen)
            if not vm.Parent then return end
            local ahora = os.clock()
            if origen == "HB" then
                -- (v6.9) un tirón se anota con lo que estaba pasando y cuánto gastó mi parte
                if ultimoHB and ahora - ultimoHB > 0.12 then
                    anotar(string.format("TIRON de %.2f s; activa=%s e=%.2f; ponerGarras gasto %.1f ms", ahora - ultimoHB,
                        activa and activa.nombre or "ninguna", ext.RightArm, gastoPoner * 1000))
                end
                ultimoHB, gastoPoner = ahora, 0
                barrer(ahora)
            end
            if activa then
                local t = ahora - activa.inicio
                if t >= activa.len then
                    activa = nil
                else
                    local pD, pI = GARRAS.poseEn(activa.kf, math.max(t, 0))
                    local w = math.clamp(math.min(1, t / 0.05, (activa.len - t) / 0.10), 0, 1) -- entra y sale suave
                    for lado, p in pairs({ RightArm = pD, LeftArm = pI }) do
                        local m = motores[lado]
                        local meta = m.C0:Inverse() * GARRAS.brazoDeMano(p, rollBase[lado], gp.mano) * m.C1
                        m.Transform = m.Transform:Lerp(meta, w)
                        ext[lado] = p.e
                    end
                end
            end
            if not activa then
                local e = ahora > listoEn and 1 or ext.RightArm
                ext.RightArm, ext.LeftArm = e, e
            end
            if origen == "HB" then
                local antes = os.clock()
                ponerGarras()
                gastoPoner = gastoPoner + (os.clock() - antes)
            end
        end

        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g) pcall(alSonar, g) end))
        for _, par in ipairs({ { RunService.Stepped, "ST" }, { RunService.Heartbeat, "HB" }, { RunService.RenderStepped, "RS" } }) do
            table.insert(r.conexiones, par[1]:Connect(function()
                local bien, fallo = pcall(actualizar, par[2])
                if not bien and not GARRAS.fallo then GARRAS.fallo = true; anotar("ERROR en actualizar: " .. tostring(fallo)) end
            end))
        end
        ponerGarras()
        local ids = {}
        for id, accion in pairs(mapa) do table.insert(ids, accion .. "=" .. id) end
        table.sort(ids)
        anotar(string.format("garras listas en %s (arma %s, skin %s); %d garras; ids: %s", vm.Name, tostring(armaReal),
            tostring(skinReal), #cuchillas, table.concat(ids, " ")))
        for _, g in ipairs(animator:GetPlayingAnimationTracks()) do pcall(alSonar, g) end
    end

    -- (v6.28) ESCUDO DEL CAPITÁN AMÉRICA (Riot Shield): Idle, golpes, equip y sprint son las animaciones del juego (con ellas el
    -- brazo derecho no se mueve respecto al escudo, así que las correas caen donde van). Solo la INSPECCIÓN es propia: cuando el
    -- juego la pone, se esconde la suya y se mueve el brazo derecho (x, y, z, yaw, phi, roll sobre su eje) y el escudo va
    -- pegado: BodyPrimary = brazo * ENLACE, donde ENLACE sale del reposo del juego (cuadro 0 del Idle). Sin locales nuevos.
    function GARRAS.escudo(r, vm, skin, armaReal, skinReal)
        local es = PROPIAS[skin.nombre] and PROPIAS[skin.nombre].escudo
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        local raiz = vm:FindFirstChild("HumanoidRootPart")
        if not (es and animator and raiz) then return end
        local brazo, cuerpo = raiz:FindFirstChild("RightArm"), nil
        for _, m in ipairs(raiz:GetChildren()) do
            if m:IsA("Motor6D") and m.Part1 and m.Part1.Name == "BodyPrimary" then cuerpo = m end
        end
        if not (brazo and cuerpo) then
            GARRAS.anotar("escudo: no encuentro el brazo derecho o la union de BodyPrimary")
            return
        end
        local function cf(t) return CFrame.new(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12]) end
        local AR0, B0 = cf(es.AR0), cf(es.B0)
        local enlace = AR0:Inverse() * B0
        local rot0 = AR0 - AR0.Position
        local campos = { "x", "y", "z", "yaw", "phi", "roll" }
        -- qué animación del juego es cada acción nuestra (Inspect, Attack1, Attack2): por el id de la pista y, de respaldo, por su nombre
        local mapa = {}
        for nombre, v in pairs(VISTAS) do
            if nombre == armaReal or v._arma == armaReal then
                for accion in pairs(es.acciones) do
                    local id = animacionDe(nombre, accion)
                    if id then mapa[id] = accion end
                end
            end
        end
        local activa = nil
        local vistas = setmetatable({}, { __mode = "k" })
        local function alSonar(g)
            if propias[g] or vistas[g] then return end
            vistas[g] = true
            local id = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            local accion = id and mapa[id]
            if not accion then
                local nombre = string.lower(g.Name or "")
                for clave in pairs(es.acciones) do
                    if nombre:find(string.lower(clave), 1, true) then accion = clave end
                end
            end
            if not accion then return end
            if activa and os.clock() - activa.inicio < 0.25 then return end
            activa = { inicio = os.clock(), pista = g, nombre = accion, a = es.acciones[accion] }
            GARRAS.anotar(string.format("escudo: empieza %s propia (%s s)", accion, tostring(activa.a.len)))
            pcall(function() g:AdjustWeight(ESCONDIDA, 0) end)
        end
        local function actualizar()
            if not (activa and vm.Parent) then return end
            local t = os.clock() - activa.inicio
            local largo = activa.a.len
            -- termina sola, o antes si el juego corta la animacion (disparaste, corriste, sacaste otra cosa)
            if t >= largo or (t > 0.4 and not activa.pista.IsPlaying) then
                activa = nil
                return
            end
            local kf = activa.a.kf
            local n = #kf
            local i = 1
            while i < n - 1 and kf[i + 1].t <= t do i = i + 1 end
            local a, b = kf[i], kf[i + 1]
            local u = math.clamp((t - a.t) / (b.t - a.t), 0, 1)
            u = (GARRAS.ease[b.ease] or GARRAS.ease.lin)(u)
            local p = {}
            for _, c in ipairs(campos) do p[c] = a[c] + (b[c] - a[c]) * u end
            local A = CFrame.new(p.x, p.y, p.z) * CFrame.Angles(0, math.rad(p.yaw), 0) * CFrame.Angles(0, 0, math.rad(p.phi))
                * rot0 * CFrame.Angles(math.rad(p.roll), 0, 0)
            local w = math.clamp(math.min(1, t / 0.08, (largo - t) / 0.2), 0, 1) -- entra y sale suave (entra rápido: los golpes son ágiles)
            brazo.Transform = brazo.Transform:Lerp(brazo.C0:Inverse() * A * brazo.C1, w)
            cuerpo.Transform = cuerpo.Transform:Lerp(cuerpo.C0:Inverse() * (A * enlace) * cuerpo.C1, w)
        end
        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g) pcall(alSonar, g) end))
        for _, par in ipairs({ { RunService.Stepped, "ST" }, { RunService.Heartbeat, "HB" }, { RunService.RenderStepped, "RS" } }) do
            table.insert(r.conexiones, par[1]:Connect(function()
                local bien, fallo = pcall(actualizar)
                if not bien and not GARRAS.fallo then GARRAS.fallo = true; GARRAS.anotar("ERROR escudo: " .. tostring(fallo)) end
            end))
        end
        for _, g in ipairs(animator:GetPlayingAnimationTracks()) do pcall(alSonar, g) end
        GARRAS.anotar(string.format("escudo listo en %s (arma %s, skin %s)", vm.Name, tostring(armaReal), tostring(skinReal)))
    end

    -- (v6.67) la pieza de verdad de un viewmodel: el juego la tiene dentro de ItemVisual ("ItemVisual.Body", con su "BodyPrimary"), no como hijo
    -- directo del viewmodel. Antes GARRAS.estela y GARRAS.telarana la buscaban con vm:FindFirstChild("Body") y no la encontraban (por eso la estela y
    -- la telaraña no salian). Devuelve la parte principal (la que se mueve con las animaciones).
    local function principalReal(vm, nombrePieza)
        local pieza = vm:FindFirstChild(nombrePieza, true)
        if not pieza then return nil end
        if pieza:IsA("BasePart") then return pieza end
        return pieza:FindFirstChild(nombrePieza .. "Primary") or pieza.PrimaryPart or pieza:FindFirstChild("Primary")
    end

    -- (v6.55) ESTELA y LUZ de una skin propia (def.estela / def.luz): una cinta (Trail) entre dos puntos del arma que aparece al atacar y al
    -- hacer dash, y una luz de color. Todo cuelga del arma en la mano (el viewmodel solo existe en TU pantalla): los demás jugadores no lo ven.
    --   estela = { punta = {x,y,z}, base = {x,y,z}, color = {r,g,b}, acciones = { "Attack1", "Attack2" }, dash = velocidad (studs/s), vida = s,
    --              pieza = "Body" }      (punta/base: en el marco de la parte Primary de la pieza)
    --   luz = { color = {r,g,b}, rango = n, brillo = n, pieza = "Body" }
    function GARRAS.estela(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local es, luz = def and def.estela, def and def.luz
        if not (es or luz) then return end
        local nombrePieza = (es and es.pieza) or (luz and luz.pieza) or "Body"
        local prim = principalReal(vm, nombrePieza)
        if not prim then
            GARRAS.anotar("estela: no encuentro la pieza " .. nombrePieza)
            return
        end
        local function col(t) return Color3.fromRGB(t[1], t[2], t[3]) end
        if luz then
            local l = Instance.new("PointLight")
            l.Color, l.Range, l.Brightness = col(luz.color), luz.rango or 8, luz.brillo or 1
            l.Name = "CieloLuz"
            l.Parent = prim
        end
        if not es then return end
        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        a0.Name, a1.Name = "CieloEstelaPunta", "CieloEstelaBase"
        a0.Position, a1.Position = Vector3.new(es.punta[1], es.punta[2], es.punta[3]), Vector3.new(es.base[1], es.base[2], es.base[3])
        a0.Parent, a1.Parent = prim, prim
        local t = Instance.new("Trail")
        t.Name = "CieloEstela"
        t.Attachment0, t.Attachment1 = a0, a1
        t.Lifetime = es.vida or 0.35
        t.MinLength = 0.04
        t.FaceCamera = true
        t.LightEmission = 0.75
        t.Color = ColorSequence.new(col(es.color), col(es.color2 or es.color))
        t.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.6, 0.55), NumberSequenceKeypoint.new(1, 1) })
        t.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2) })
        t.Enabled = false
        t.Parent = prim
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        local mapa = {}
        for nombre, v in pairs(VISTAS) do
            if nombre == armaReal or v._arma == armaReal then
                for _, accion in ipairs(es.acciones or {}) do
                    local id = animacionDe(nombre, accion)
                    if id then mapa[id] = true end
                end
            end
        end
        local hasta = 0
        local function ataque(g)
            if propias[g] then return end
            local id = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            if id and mapa[id] then hasta = math.max(hasta, os.clock() + math.max(g.Length, 0.3) / math.max(g.Speed, 0.1)) end
        end
        if animator then
            table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g) pcall(ataque, g) end))
            for _, g in ipairs(animator:GetPlayingAnimationTracks()) do pcall(ataque, g) end
        end
        table.insert(r.conexiones, RunService.Heartbeat:Connect(function()
            local activa = os.clock() < hasta
            if not activa and es.dash then
                local ch = jugador.Character
                local raiz = ch and ch:FindFirstChild("HumanoidRootPart")
                if raiz then
                    local v = raiz.AssemblyLinearVelocity
                    activa = Vector3.new(v.X, 0, v.Z).Magnitude > es.dash
                end
            end
            if t.Enabled ~= activa then t.Enabled = activa end
        end))
        GARRAS.anotar("estela lista en " .. vm.Name .. " (" .. tostring(skin.nombre) .. ")")
    end

    -- (v6.67) MIRA (def.mira = { centro = {x,y,z} }): el centro del agujero/mira de la skin, en el marco del cuerpo del arma. Al apuntar, el juego pone
    -- la camara en el _aim_position del arma de verdad. Pero con las skins propias el agujero se veia unos 0.03 studs fuera de la mirilla (el juego mueve
    -- el modelo un poco cuando cambian las piezas), asi que aqui se corrige en vivo: cada cuadro, si estas apuntando, se mide cuanto se aparta el rayo de
    -- tu camara del centro del agujero y se corre el _aim_position del arma de verdad esa diferencia (con tope), hasta que la mirilla cae en el centro.
    function GARRAS.mira(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local cfg = def and def.mira
        if not cfg then return end
        local prim = principalReal(vm, "Body")
        local ap = prim and prim:FindFirstChild("_aim_position")
        if not (prim and ap and ap:IsA("Attachment")) then
            GARRAS.anotar("mira: no encuentro _aim_position")
            return
        end
        r.adjuntos[ap] = r.adjuntos[ap] or ap.CFrame
        local base = r.adjuntos[ap]
        local limite = cfg.limite or 0.09
        local hx, hy, hz = cfg.centro[1], cfg.centro[2], cfg.centro[3]
        local ax, ay = 0, 0
        local ultimo = 0
        table.insert(r.conexiones, RunService.RenderStepped:Connect(function()
            if not (prim.Parent and ap.Parent) then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local o = prim.CFrame:PointToObjectSpace(cam.CFrame.Position)
            local d = prim.CFrame:VectorToObjectSpace(cam.CFrame.LookVector)
            if d.Z > -0.3 then return end
            if (o - base.Position).Magnitude > 0.45 then return end          -- no estas apuntando
            local t = (hz - o.Z) / d.Z
            local px, py = o.X + d.X * t, o.Y + d.Y * t
            local ex, ey = hx - px, hy - py
            if math.abs(ex) > 0.15 or math.abs(ey) > 0.15 then return end
            ax = math.clamp(ax + ex * 0.2, -limite, limite)
            ay = math.clamp(ay + ey * 0.2, -limite, limite)
            ap.CFrame = base + Vector3.new(ax, ay, 0)
            if os.clock() - ultimo > 2 then
                ultimo = os.clock()
                GARRAS.anotar(string.format("mira: error x=%.4f y=%.4f  ajuste x=%.4f y=%.4f", ex, ey, ax, ay))
            end
        end))
        GARRAS.anotar("mira lista en " .. vm.Name .. " (" .. tostring(skin.nombre) .. ")")
    end

    -- (v6.94) SILENCIAR USO (def.silenciarUso): cuando el juego empieza la animacion de USAR del arma, durante def.silenciarUso segundos el primer sonido nuevo del juego se cambia
    -- por uno de los de la skin (aunque su id no se conozca) y los demas se callan. Lo lee alCrearSonido (GARRAS.usoActivo).
    function GARRAS.silenciarUso(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        if not (def and def.silenciarUso and animator) then return end
        local ids = {}
        for nombre, v in pairs(VISTAS) do
            if nombre == armaReal or v._arma == armaReal then
                local id = animacionDe(nombre, "Use")
                if id then ids[id] = true end
            end
        end
        local clave = norm(def.arma) .. "_" .. norm(skin.nombre) .. "_use"
        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g)
            if propias[g] then return end
            local id = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            if id and ids[id] and SONIDOS[clave] then
                GARRAS.usoActivo = { hasta = os.clock() + def.silenciarUso, ids = SONIDOS[clave], sono = false }
            end
        end))
        GARRAS.anotar("silenciarUso listo en " .. vm.Name .. " (" .. tostring(skin.nombre) .. ")")
    end

    -- (v6.94) PARLANTE (def.parlante): para que se entienda que es un parlante, al sonar LATE: los conos y las tapas de los altavoces se hinchan con cada golpe, los aros de luz
    -- destellan en blanco y salen notas musicales (rosa a celeste) por arriba. GARRAS.latidoParlante(segundos) lo llama alCrearSonido cuando suena un troll (ids.latido).
    function GARRAS.parlante(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        if not (def and def.parlante) then return end
        local carpeta = r.carpeta
        if not carpeta then
            GARRAS.anotar("parlante: no hay carpeta de la skin")
            return
        end
        local conos, aros, base = {}, {}, nil
        for _, d in ipairs(carpeta:GetDescendants()) do
            if d:IsA("BasePart") then
                if d.Name:find("cono$") or d.Name:find("tapa de polvo$") then
                    table.insert(conos, { p = d, tam = d.Size })
                elseif d.Name:find("aro de luz") then
                    table.insert(aros, { p = d, color = d.Color })
                elseif d.Name == "Cuerpo centro" then
                    base = d
                end
            end
        end
        GARRAS.anotar("parlante: " .. #conos .. " conos, " .. #aros .. " aros de luz, cuerpo " .. tostring(base ~= nil))
        -- las notas: dos texturas de pixeles (corchea y dos corcheas) que suben desde el cuerpo
        local emisores = {}
        if base then
            for i = 1, 2 do
                local ok, tex = pcall(cargarAsset, ruta("parlante_nota_" .. i .. ".png"))
                if ok and type(tex) == "string" and tex ~= "" then
                    local e = Instance.new("ParticleEmitter")
                    e.Name = "CieloNotas"
                    e.Texture = tex
                    e.Rate = 0
                    e.Enabled = false
                    e.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 52, 190)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 220, 240)),
                    })
                    e.LightEmission = 0.7
                    e.LightInfluence = 0
                    e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0.42), NumberSequenceKeypoint.new(1, 0.3) })
                    e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0.05), NumberSequenceKeypoint.new(0.8, 0.2), NumberSequenceKeypoint.new(1, 1) })
                    e.Lifetime = NumberRange.new(1.1, 1.7)
                    e.Speed = NumberRange.new(1.4, 2.6)
                    e.SpreadAngle = Vector2.new(38, 38)
                    e.Rotation = NumberRange.new(-18, 18)
                    e.RotSpeed = NumberRange.new(-35, 35)
                    e.Acceleration = Vector3.new(0, 0.4, 0)
                    e.EmissionDirection = Enum.NormalId.Top
                    e.Parent = base
                    table.insert(emisores, e)
                end
            end
        end
        local fin = 0
        local corre = false
        local function restaurar()
            for _, c in ipairs(conos) do if c.p.Parent then c.p.Size = c.tam end end
            for _, a in ipairs(aros) do if a.p.Parent then a.p.Color = a.color end end
            for _, e in ipairs(emisores) do e.Rate = 0 e.Enabled = false end
        end
        GARRAS.latidoParlante = function(duracion)
            fin = os.clock() + (duracion or 2.4)
            if corre then return end
            corre = true
            local inicio = os.clock()
            for _, e in ipairs(emisores) do e.Rate = 9 e.Enabled = true end
            task.spawn(function()
                while vivo and os.clock() < fin and base and base.Parent do
                    local t = os.clock() - inicio
                    local k = 1 - (t * 4.2) % 1            -- 1 en cada golpe, baja a 0 hasta el siguiente
                    local hincha = 1 + 0.12 * k * k
                    for _, c in ipairs(conos) do if c.p.Parent then c.p.Size = c.tam * hincha end end
                    for i, a in ipairs(aros) do
                        if a.p.Parent then
                            local ola = math.max(0, k - 0.35 * ((i - 1) % 12) / 12)
                            a.p.Color = a.color:Lerp(Color3.new(1, 1, 1), math.clamp(ola, 0, 1) * 0.85)
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
                restaurar()
                corre = false
            end)
        end
        table.insert(r.conexiones, { Disconnect = function() GARRAS.latidoParlante = nil restaurar() end })
    end

    -- (v6.80) TOCAR (def.tocar): la animacion de USAR de una skin propia hecha con la mano IZQUIERDA (el parlante: toca un punto al azar como un boton). Cuando el juego
    -- empieza su animacion "Use" del arma, durante def.tocar.total segundos Cielo mueve el brazo izquierdo: llega al punto elegido (objetivos: posicion p y normal n en el marco de
    -- la pieza), lo toca a los def.tocar.llegada segundos, lo suelta y vuelve. El brazo es una caja de 1.8 de largo y su MANO esta en el extremo -X: se pone con ese extremo sobre el
    -- punto y su eje mirando hacia adentro del parlante (un poco hacia adelante, como llega un brazo de verdad). Mezcla con la animacion del juego (peso) al entrar y al salir.
    function GARRAS.tocar(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local cfg = def and def.tocar
        if not cfg then return end
        local anotar = GARRAS.anotar
        local raizVM = vm:FindFirstChild("HumanoidRootPart")
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        local motor = raizVM and raizVM:FindFirstChild("LeftArm")
        local prim = principalReal(vm, cfg.pieza or "Body")
        if not (raizVM and animator and motor and prim) then
            anotar("tocar: falta algo (raiz/animador/brazo/pieza)")
            return
        end
        local ids = {}
        for nombre, v in pairs(VISTAS) do
            if nombre == armaReal or v._arma == armaReal then
                local id = animacionDe(nombre, "Use")
                if id then ids[id] = true end
            end
        end
        local objetivos = cfg.objetivos or {}
        local llegada, total = cfg.llegada or 0.3, cfg.total or 1.15
        local activa, ultimo = nil, 0
        local function empezar()
            if os.clock() - (activa and activa.t0 or -10) < 0.3 then return end
            local i = math.random(#objetivos)
            if #objetivos > 1 and i == ultimo then i = i % #objetivos + 1 end
            ultimo = i
            activa = { t0 = os.clock(), obj = objetivos[i] }
            anotar("tocar: objetivo " .. i)
        end
        local function suave(x) x = math.clamp(x, 0, 1) return x * x * (3 - 2 * x) end
        local function actualizar()
            if not activa then return end
            local t = os.clock() - activa.t0
            if t > total then activa = nil return end
            if not (prim.Parent and raizVM.Parent and motor.Parent) then return end
            local o = activa.obj
            local P = prim.CFrame:PointToWorldSpace(Vector3.new(o.p[1], o.p[2], o.p[3]))
            local N = prim.CFrame:VectorToWorldSpace(Vector3.new(o.n[1], o.n[2], o.n[3])).Unit
            -- distancia de la mano a la superficie: se acerca, toca (0), mantiene un instante y se separa
            local d
            if t < llegada then d = 0.22 * (1 - suave(t / llegada)) + 0.012
            elseif t < llegada + 0.10 then d = 0.012 - 0.012 * suave((t - llegada) / 0.04)
            elseif t < llegada + 0.18 then d = 0
            else d = 0.20 * suave((t - llegada - 0.18) / 0.3) end
            local H = P + N * d
            -- la mano mira hacia adentro del parlante, un poco hacia adelante (-Z de la camara)
            local adelante = raizVM.CFrame:VectorToWorldSpace(Vector3.new(0, 0, -1))
            local D = (-N + adelante * 0.6).Unit
            local X = -D
            local arriba = Vector3.new(0, 1, 0)
            local Y0 = arriba - X * X:Dot(arriba)
            if Y0.Magnitude < 1e-3 then Y0 = Vector3.new(0, 0, 1) end
            Y0 = Y0.Unit
            local Z0 = X:Cross(Y0)
            local centro = H - D * 0.9
            local brazoMundo = CFrame.fromMatrix(centro, X, Y0, Z0)
            local enRaiz = raizVM.CFrame:ToObjectSpace(brazoMundo)
            local meta = motor.C0:Inverse() * enRaiz * motor.C1
            local w = math.min(suave(t / 0.22), 1 - suave((t - (total - 0.35)) / 0.35))
            motor.Transform = motor.Transform:Lerp(meta, math.clamp(w, 0, 1))
        end
        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g)
            if propias[g] then return end
            local id = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            if id and ids[id] then pcall(empezar) end
        end))
        for _, par in ipairs({ { RunService.Stepped, "ST" }, { RunService.Heartbeat, "HB" }, { RunService.RenderStepped, "RS" } }) do
            table.insert(r.conexiones, par[1]:Connect(function()
                local bien, fallo = pcall(actualizar)
                if not bien and not GARRAS.fallo2 then GARRAS.fallo2 = true; anotar("ERROR en tocar: " .. tostring(fallo)) end
            end))
        end
        anotar("tocar listo en " .. vm.Name .. " (" .. tostring(skin.nombre) .. "): " .. #objetivos .. " objetivos")
    end

    -- (v6.66) TELARAÑA (def.telarana): el lanzatelarañas del Grappler. Cuando disparas el gancho el juego crea en workspace una Part "Hook" (1x1,
    -- transparente, con un BodyVelocity que la empuja) y le pega encima el modelo de la skin. Aquí se esconde todo lo que trae (el gancho del
    -- juego y su cuerda de resorte) y se le pone una bolita de telaraña, y la CUERDA es un Beam blanco fino entre la boquilla del aparato de la
    -- muñeca (un Attachment que se crea en la pieza Body) y la Part del gancho. Todo es local: solo lo ves tú.
    --   telarana = { pieza = "Body", boquilla = {x,y,z}, color = {r,g,b}, grosor = studs }
    function GARRAS.telarana(r, vm, skin, armaReal, skinReal)
        local def = PROPIAS[skin.nombre]
        local cfg = def and def.telarana
        if not cfg then return end
        local prim = principalReal(vm, cfg.pieza or "Body")
        if not prim then
            GARRAS.anotar("telarana: no encuentro la pieza " .. tostring(cfg.pieza or "Body"))
            return
        end
        local b = cfg.boquilla
        local boq = Instance.new("Attachment")
        boq.Name = "CieloBoquilla"
        boq.Position = Vector3.new(b[1], b[2], b[3])
        boq.Parent = prim
        local c = cfg.color or { 246, 246, 250 }
        local blanco = Color3.fromRGB(c[1], c[2], c[3])
        local grosor = cfg.grosor or 0.07
        local function esconder(d)
            if d:IsA("BasePart") then
                if not d:GetAttribute("CieloTela") then d.Transparency = 1 end
            elseif d:IsA("SpringConstraint") or d:IsA("RopeConstraint") then
                d.Visible = false
            elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") then
                if not d:GetAttribute("CieloTela") then d.Enabled = false end   -- (v6.68) sin esto se apagaba tambien NUESTRO hilo
            end
        end
        local function vestir(hook)
            -- (v6.69) se engancha YA (sin esperar un cuadro): el primer disparo mostraba el gancho del juego un instante
            hook.DescendantAdded:Connect(function(d) task.defer(function() pcall(esconder, d) end) end)
            for _, d in ipairs(hook:GetDescendants()) do pcall(esconder, d) end
            task.wait()
            if not hook.Parent then return end
            for _, d in ipairs(hook:GetDescendants()) do pcall(esconder, d) end
            -- la bolita del final de la telaraña
            local bola = Instance.new("Part")
            bola.Name = "CieloTelaBola"
            bola.Shape = Enum.PartType.Ball
            bola.Size = Vector3.new(0.34, 0.34, 0.34)
            bola.Material = Enum.Material.SmoothPlastic
            bola.Color = blanco
            bola.Massless = true
            bola.CanCollide, bola.CanQuery, bola.CanTouch = false, false, false
            bola.Anchored = false
            bola:SetAttribute("CieloTela", true)
            bola.CFrame = hook.CFrame
            bola.Parent = hook
            local w = Instance.new("WeldConstraint")
            w.Part0, w.Part1 = hook, bola
            w.Parent = bola
            -- la cuerda: un hilo blanco fino y, debajo, un resplandor mas ancho y casi transparente
            local punta = Instance.new("Attachment")
            punta.Name = "CieloTelaPunta"
            punta.Parent = hook
            local hilo = Instance.new("Beam")
            hilo.Name = "CieloTelaHilo"
            hilo:SetAttribute("CieloTela", true)
            hilo.Attachment0, hilo.Attachment1 = boq, punta
            hilo.Width0, hilo.Width1 = grosor, grosor
            hilo.Segments = 1
            hilo.FaceCamera = true
            hilo.Color = ColorSequence.new(blanco)
            hilo.LightEmission = 0.55
            hilo.LightInfluence = 0
            hilo.Transparency = NumberSequence.new(0)
            hilo.Parent = hook
            local brillo = hilo:Clone()
            brillo.Name = "CieloTelaBrillo"
            brillo.Width0, brillo.Width1 = grosor * 3, grosor * 3
            brillo.LightEmission = 1
            brillo.Transparency = NumberSequence.new(0.8)
            brillo.Parent = hook
        end
        -- (v6.69) ANIMACION DEL DISPARO, simple: al salir el gancho todo el aparato da una patada hacia atras (hacia el codo) que vuelve rapido,
        -- el piston de la boquilla retrocede un poco mas y vuelve, sale un destello blanco con una rafaga de chispitas de telaraña hacia adelante.
        -- Las piezas del aparato van pegadas con un Weld cada una (Part0 = la parte principal del arma): se mueve su C0 y se devuelve.
        local piezas = {}
        if r.carpeta then
            for _, d in ipairs(r.carpeta:GetChildren()) do
                local w = d:IsA("BasePart") and d:FindFirstChildOfClass("Weld")
                if w then
                    table.insert(piezas, { w = w, c0 = w.C0, boq = d.Name == "Collar de la boquilla" or d.Name == "Tapon de la boquilla" or d.Name == "Aro del tapon" })
                end
            end
        end
        local emisor = Instance.new("ParticleEmitter")
        emisor.Name = "CieloTelaChispas"
        emisor.Rate = 0
        emisor.Lifetime = NumberRange.new(0.18, 0.32)
        emisor.Speed = NumberRange.new(9, 17)
        emisor.SpreadAngle = Vector2.new(22, 22)
        emisor.EmissionDirection = Enum.NormalId.Front
        emisor.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.07), NumberSequenceKeypoint.new(1, 0) })
        emisor.Color = ColorSequence.new(blanco)
        emisor.LightEmission = 1
        emisor.LightInfluence = 0
        emisor.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        emisor.Parent = boq
        local luz = Instance.new("PointLight")
        luz.Name = "CieloTelaDestello"
        luz.Color = blanco
        luz.Range = 7
        luz.Brightness = 2.5
        luz.Enabled = false
        luz.Parent = boq
        local DUR = 0.3
        local t0, animando = -10, false
        local function disparo()
            t0 = os.clock()
            pcall(function() emisor:Emit(14) end)
            luz.Enabled = true
        end
        table.insert(r.conexiones, RunService.RenderStepped:Connect(function()
            local t = os.clock() - t0
            if t >= DUR then
                if animando then
                    animando = false
                    luz.Enabled = false
                    for _, p in ipairs(piezas) do p.w.C0 = p.c0 end
                end
                return
            end
            animando = true
            local k = (1 - t / DUR)
            k = k * k * k
            local piston = math.sin(math.min(t / 0.2, 1) * math.pi)
            luz.Brightness = 2.5 * k
            for _, p in ipairs(piezas) do
                local z = 0.055 * k + (p.boq and 0.05 * piston or 0)
                p.w.C0 = CFrame.new(0, 0.012 * k, z) * p.c0
            end
        end))
        table.insert(r.conexiones, workspace.ChildAdded:Connect(function(o)
            if o.Name == "Hook" and o:IsA("BasePart") then
                pcall(disparo)
                task.spawn(function() pcall(vestir, o) end)
            end
        end))
        GARRAS.anotar("telarana lista en " .. vm.Name .. " (" .. tostring(skin.nombre) .. ")")
    end

    -- si el juego le cambia después el peso o la velocidad a la suya, la nuestra lo sigue
    local function seguirAnimaciones()
        for _, r in pairs(registro) do
            for g, par in pairs(r.anim and r.anim.pares or {}) do
                if par.activo then
                    local w = g.WeightTarget
                    if math.abs(w - par.puesto) > 0.0001 then
                        par.peso = w
                        par.nuestra:AdjustWeight(w, 0.1)
                        if w > 0 then
                            g:AdjustWeight(ESCONDIDA, 0)
                            par.puesto = ESCONDIDA
                        else
                            par.puesto = w
                        end
                    end
                    if g.Speed ~= par.velocidad then
                        par.velocidad = g.Speed
                        par.nuestra:AdjustSpeed(g.Speed * par.factor)
                    end
                end
            end
        end
    end
    table.insert(conexionesUI, RunService.Heartbeat:Connect(function() pcall(seguirAnimaciones) end))

    -- mueve los wraps animados de las armas que se ven; lo que tarda cada pasada decide cuándo toca la siguiente
    table.insert(conexionesUI, RunService.Heartbeat:Connect(function()
        local ahora = os.clock()
        if ahora < WRAPANIM.proximo then return end
        local hubo = false
        local t = workspace:GetServerTimeNow()
        for vm, r in pairs(registro) do
            if r.animados and vm.Parent then
                local visible = false
                for _, g in ipairs(r.grupos) do
                    if g.v and g.v < 1 then visible = true break end
                end
                if visible then
                    hubo = true
                    for objeto, e in pairs(r.animados) do
                        local f = WRAPANIM.fn[objeto]
                        if f then
                            local dt = e.ult and ahora - e.ult or 0
                            e.ult = ahora
                            local bien, fallo = pcall(f, e, t, dt)
                            if not bien and not e.fallo then
                                e.fallo = true
                                GARRAS.anotar("wrap animado " .. objeto .. ": " .. tostring(fallo))
                            end
                        end
                    end
                end
            end
        end
        local costo = os.clock() - ahora
        -- como mucho ~6 % del tiempo: si cada pasada cuesta 1 ms va a 60 por segundo; si cuesta 10 ms, a unas 6
        WRAPANIM.proximo = hubo and (ahora + math.clamp(costo * 16, 1 / 60, 0.3)) or (ahora + 0.25)
        if hubo and costo > 0.004 and not WRAPANIM.avisado then
            WRAPANIM.avisado = true
            GARRAS.anotar(string.format("wraps animados: cada pasada cuesta %.1f ms", costo * 1000))
        end
    end))

    -- La unión de cada pieza con el arma (Motor6D) va con la posición base (C0/C1) de la skin,
    -- que es con la que se hicieron sus animaciones. Si el juego la vuelve a poner, se anota la
    -- suya (para devolverla al quitar la skin) y va otra vez la de la skin.
    local function casiIgual(a, b)
        return (a.Position - b.Position).Magnitude < 1e-4 and a.LookVector:Dot(b.LookVector) > 0.99999
            and a.UpVector:Dot(b.UpVector) > 0.99999
    end

    local function fijarMotor(r, motor, c0, c1)
        r.motores[motor] = { motor.C0, motor.C1 }
        motor.C0, motor.C1 = c0, c1
        for i, propiedad in ipairs({ "C0", "C1" }) do
            local mio = i == 1 and c0 or c1
            table.insert(r.conexiones, motor:GetPropertyChangedSignal(propiedad):Connect(function()
                if not casiIgual(motor[propiedad], mio) then
                    r.motores[motor][i] = motor[propiedad]
                    motor[propiedad] = mio
                end
            end))
        end
    end

    local function quitarSkin(vm)
        local r = registro[vm]
        if not r then return end
        registro[vm] = nil
        for _, con in ipairs(r.conexiones) do con:Disconnect() end
        soltarAnimaciones(r)
        for motor, antes in pairs(r.motores) do
            pcall(function() motor.C0, motor.C1 = antes[1], antes[2] end)
        end
        for adjunto, antes in pairs(r.adjuntos) do
            pcall(function() adjunto.CFrame = antes end)
        end
        for parte, e in pairs(r.llavero) do
            pcall(function() parte.LocalTransparencyModifier = e.juego end)
        end
        for parte, tam in pairs(r.ocultas) do
            pcall(function() parte.Size = tam end)
        end
        for malla, escala in pairs(r.mallas) do
            pcall(function() malla.Scale = escala end)
        end
        for efecto, valor in pairs(r.efectos) do
            pcall(function() efecto.Enabled = valor end)
        end
        for _, textura in ipairs(r.texturas) do
            pcall(function() textura:Destroy() end)
        end
        for parte, antes in pairs(r.materiales) do
            pcall(function()
                parte.Material, parte.Color, parte.Reflectance = antes[1], antes[2], antes[3]
                parte.MaterialVariant = antes[4] or ""
            end)
        end
        if r.pivote then
            pcall(function() r.pivote[1].CFrame = r.pivote[2] end)
        end
        if r.carpeta then r.carpeta:Destroy() end
    end

    -- El llavero cuelga de un punto del cuerpo del arma (_charm_pivot_attachment): se mueve
    -- adonde lo tiene la skin, para que no quede colgando en el aire
    local function moverLlavero(r, cuerpoVivo, cuerpoSkin)
        local modeloVivo = cuerpoVivo and cuerpoVivo:FindFirstChild("_charm_attachment_model")
        local modeloSkin = cuerpoSkin and cuerpoSkin:FindFirstChild("_charm_attachment_model")
        local pv, ps = cuerpoVivo and principalDe(cuerpoVivo), cuerpoSkin and principalDe(cuerpoSkin)
        local av = modeloVivo and modeloVivo:FindFirstChild("_charm_pivot_attachment", true)
        local as = modeloSkin and modeloSkin:FindFirstChild("_charm_pivot_attachment", true)
        if not (pv and ps and av and as and av.Parent:IsA("BasePart")) then return end
        local enSkin = ps.CFrame:ToObjectSpace(as.WorldCFrame)
        local enVivo = pv.CFrame:ToObjectSpace(av.Parent.CFrame)
        r.pivote = { av, av.CFrame }
        av.CFrame = enVivo:Inverse() * enSkin
    end

    -- skin: la del catálogo que se va a mostrar (la elegida, o la de verdad si solo hay wrap u
    --       opacidad: así la original también se puede ver a medias)
    -- libVivo: la del catálogo que corresponde al arma de verdad (para saber cómo está armada)
    -- opacidad: de 0 (no se ve) a 1
    local function vestir(vm, skin, wrap, clave, libVivo, opacidad)
        quitarSkin(vm)
        local item = vm:FindFirstChild("ItemVisual")
        local raiz = vm:FindFirstChild("HumanoidRootPart")
        if not (item and raiz) then return end
        local r = {
            ocultas = {}, mallas = {}, efectos = {}, conexiones = {}, texturas = {}, grupos = {}, llavero = {},
            motores = {}, adjuntos = {}, ocultables = {}, materiales = {},
            clave = clave, wrap = wrap and wrap.nombre or nil, opacidad = opacidad or 1, inv = wrap and wrap.invertido or nil,
        }
        registro[vm] = r

        local vivas, primeraViva = {}, nil
        for _, pieza in ipairs(item:GetChildren()) do
            if pieza:IsA("Model") then
                vivas[pieza.Name] = pieza
                primeraViva = primeraViva or pieza
            end
        end
        -- las que van dentro de los brazos (puños y guantes)
        for nombrePieza, nombreBrazo in pairs(BRAZOS) do
            local brazo = vm:FindFirstChild(nombreBrazo)
            local pieza = brazo and brazo:FindFirstChild(nombrePieza)
            if pieza and pieza:IsA("Model") then vivas[nombrePieza] = pieza end
        end

        -- Skin de la misma arma con animaciones propias ("exacta"): el arma se mueve con las de la
        -- skin, y cada pieza que las dos tienen toma la posición base (C0/C1) de la skin. Así la
        -- pieza de verdad se mueve igual que la de la skin, y su copia va pegada justo encima.
        local armaReal, skinReal = armaDe(vm)
        local cambios = skin and mismaFamilia(armaDeLaSkin(skin), armaReal)
            and cambiosDeAnimacion(skinReal or armaReal, skin.nombre) or nil
        local exacta = cambios ~= nil

        -- Algunas skins van en otro lugar frente a la cámara (RootPartOffset: el Keyvolver, más
        -- adelante). Se corre el arma entera, brazos incluidos, moviendo sus uniones con la raíz,
        -- que el juego no vuelve a poner en cada cuadro (la cámara no se toca).
        local corrimiento = nil
        if skin then
            -- (v6.0) una skin sin posición propia hereda la de su arma (como en el juego)
            local antes = POSICIONES[skinReal or armaReal] or POSICIONES[armaReal] or {}
            local ahora = POSICIONES[skin.nombre] or POSICIONES[armaDeLaSkin(skin) or ""] or {}
            local d = Vector3.new((ahora[1] or 0) - (antes[1] or 0), (ahora[2] or 0) - (antes[2] or 0),
                (ahora[3] or 0) - (antes[3] or 0))
            if d.Magnitude > 1e-4 then corrimiento = CFrame.new(d) end
        end

        local motores = {}
        for _, m in ipairs(raiz:GetChildren()) do
            if m:IsA("Motor6D") and m.Part1 then motores[m.Part1] = m end
        end
        local deseados = {} -- unión -> { C0, C1 } que va a tener
        if exacta then
            for nombre, pieza in pairs(vivas) do
                local deSkin = skin.modelo:FindFirstChild(nombre)
                local motor = motores[principalDe(pieza)]
                local c0 = deSkin and deSkin:GetAttribute("C0")
                if motor and typeof(c0) == "CFrame" then
                    local c1 = deSkin:GetAttribute("C1")
                    deseados[motor] = { c0, typeof(c1) == "CFrame" and c1 or CFrame.new() }
                end
            end
        end
        if corrimiento then
            for parte, m in pairs(motores) do
                if parte.Name ~= "Camera" then
                    local d = deseados[m] or { m.C0, m.C1 }
                    deseados[m] = { corrimiento * d[1], d[2] }
                end
            end
        end
        for motor, d in pairs(deseados) do fijarMotor(r, motor, d[1], d[2]) end

        local porGuia = {}
        local function grupoDe(guia)
            local g = porGuia[guia]
            if not g then
                g = { guia = guia, cosas = {}, efectos = {}, r = r }
                -- testigo: una parte visible de la pieza de verdad (no la principal ni el llavero);
                -- si la guía es un brazo, el brazo mismo
                local principal = principalDe(guia)
                if guia:IsA("BasePart") then
                    g.testigo = guia
                else
                    for _, d in ipairs(guia:GetDescendants()) do
                        if d:IsA("BasePart") and d ~= principal and d.Transparency < 0.99 and not enLlavero(d, guia) then
                            g.testigo = d
                            break
                        end
                    end
                end
                porGuia[guia] = g
                table.insert(r.grupos, g)
            end
            return g
        end

        local function ponerWrap(parte, g)
            if not wrap then return end
            ponerWrapEn(parte, wrap, function(copia, objeto, esParte)
                if not esParte then
                    table.insert(r.texturas, copia)
                    if copia:IsA("ParticleEmitter") then
                        g.efectos[copia] = copia.Enabled
                    else
                        table.insert(g.cosas, copia)
                    end
                end
                -- (v6.15) lo de un wrap animado lo mueve WRAPANIM: texturas en e.copias y piezas en e.partes
                if objeto and WRAPANIM.fn[objeto] then
                    r.animados = r.animados or {}
                    local e = r.animados[objeto]
                    if not e then
                        e = { copias = {}, partes = {} }
                        r.animados[objeto] = e
                    end
                    if esParte then
                        table.insert(e.partes, copia)
                    elseif copia:IsA("Texture") then
                        table.insert(e.copias, copia)
                    end
                end
            end, not skin and r.materiales or nil) -- sin skin va sobre piezas de verdad: hay que devolverlas
        end

        if skin then
            -- 1) el arma de verdad se achica hasta desaparecer (con sus texturas). Así su
            --    Transparency y su LocalTransparencyModifier quedan libres para el juego, y las
            --    piezas de la skin los copian. También se achica el enganche del llavero (se pone
            --    el de la skin más abajo); el llavero mismo se queda.
            for nombrePieza, pieza in pairs(vivas) do
                local principal = principalDe(pieza)
                -- (v6.23) una skin propia con soloSuyas (la espada de diamante) solo esconde las piezas que trae (el Body): las
                -- demás (las frutas de la inspección rara de la Katana) se quedan como las pone el juego
                local propiaDef = PROPIAS[skin.nombre]
                local conservar = propiaDef and propiaDef.soloSuyas and not propiaDef.piezas[nombrePieza]
                for _, d in ipairs(conservar and {} or pieza:GetDescendants()) do
                    if d:IsA("BasePart") and d ~= principal and d.Transparency < 0.99 then
                        r.ocultas[d] = d.Size
                        d.Size = DIMINUTO
                        table.insert(r.conexiones, d:GetPropertyChangedSignal("Size"):Connect(function()
                            if d.Size.Magnitude > 0.01 then
                                r.ocultas[d] = d.Size
                                d.Size = DIMINUTO
                            end
                        end))
                        -- una malla especial (SpecialMesh) no se achica con la parte: se achica aparte
                        for _, malla in ipairs(d:GetChildren()) do
                            if malla:IsA("DataModelMesh") then
                                r.mallas[malla] = malla.Scale
                                malla.Scale = DIMINUTO
                            end
                        end
                    elseif esEfecto(d) then
                        r.efectos[d] = d.Enabled
                        d.Enabled = false
                    end
                end
            end
            -- el enganche del llavero solo existe si tienes un llavero puesto (va en el cuerpo, o en
            -- la mano derecha de los puños)
            local piezaLlavero = nil
            for _, pieza in pairs(vivas) do
                if pieza:FindFirstChild("_charm_attachment_model", true) then
                    piezaLlavero = pieza
                    break
                end
            end
            local conLlavero = piezaLlavero ~= nil

            -- 2) cada pieza de la skin va pegada a su pieza de verdad, en la posición que le da
            --    la skin: así sigue las animaciones y nada queda flotando.
            --    Si la skin es de otra arma, se calza su cuerpo sobre el cuerpo de verdad.
            local alinear = CFrame.new()
            local cuerpoSkin = skin.modelo:FindFirstChild("Body")
            local reposoSkin = cuerpoSkin and reposo(cuerpoSkin)
            local reposoVivo = vivas.Body and reposo(vivas.Body)
            if reposoSkin and reposoVivo then alinear = reposoVivo * reposoSkin:Inverse() end

            -- dónde va una pieza de la skin respecto a su pieza de verdad: lo que las separa
            -- cuando las dos armas están armadas (biblioteca). Si falta algo, con los C0.
            local modeloVivo = libVivo and libVivo.modelo
            local function ubicar(ancla, piezaSkin)
                local enSkin = enModelo(skin.modelo, gemela(skin.modelo, piezaSkin))
                local piezaLib = modeloVivo and modeloVivo:FindFirstChild(ancla.Name)
                local enVivo = piezaLib and enModelo(modeloVivo, gemela(modeloVivo, piezaLib))
                if enSkin and enVivo then return enVivo:Inverse() * enSkin end
                local c0Skin, c0Vivo = reposo(piezaSkin), reposo(ancla)
                if c0Skin and c0Vivo then return c0Vivo:Inverse() * alinear * c0Skin end
                return CFrame.new()
            end

            local carpeta = Instance.new("Folder")
            carpeta.Name = "CieloSkin"

            -- (exacta) una pieza de la skin que el arma de verdad no tiene: se le arma su propia
            -- unión con la raíz, con su C0/C1, y su parte principal se llama como las del juego
            -- ("Bullets2Primary"). Así la animación de la skin también la mueve.
            local function unionPropia(piezaSkin)
                local c0, c1 = piezaSkin:GetAttribute("C0"), piezaSkin:GetAttribute("C1")
                if typeof(c0) ~= "CFrame" then return nil end
                c1 = typeof(c1) == "CFrame" and c1 or CFrame.new()
                if corrimiento then c0 = corrimiento * c0 end
                local principal = crear("Part", {
                    Name = piezaSkin.Name .. "Primary", Size = Vector3.new(0.05, 0.05, 0.05), Transparency = 1,
                    CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
                    CFrame = raiz.CFrame * c0 * c1:Inverse(), Parent = carpeta,
                })
                crear("Motor6D", { Name = "CieloUnion", Part0 = raiz, Part1 = principal, C0 = c0, C1 = c1, Parent = carpeta })
                return principal
            end
            for _, piezaSkin in ipairs(skin.modelo:GetChildren()) do
                if piezaSkin:IsA("Model") and piezaSkin.Name ~= "_charm_attachment_model" and piezaSkin.Name ~= "_fake" then
                    local principalSkin = principalDe(piezaSkin)
                    local brazo = BRAZOS[piezaSkin.Name] and vm:FindFirstChild(BRAZOS[piezaSkin.Name])
                    local guia, principalViva, desfase = nil, nil, nil
                    if brazo then
                        -- los guantes y lo demás de los puños: pegados al brazo, que es donde el
                        -- juego pone su principal
                        guia, principalViva, desfase = brazo, brazo, CFrame.new()
                    else
                        local ancla = anclaPara(piezaSkin.Name, vivas) or primeraViva
                        local contexto = piezaSkin:GetAttribute("AnimationContexts")
                        if contexto and not (ancla and ancla:GetAttribute("AnimationContexts") == contexto) then
                            -- pieza que solo sale en una animación (ej. la recarga): va con la pieza de
                            -- verdad que sale en esa misma animación; si el arma no tiene, no se muestra
                            ancla = nil
                            for _, p in pairs(vivas) do
                                if p:GetAttribute("AnimationContexts") == contexto then
                                    ancla = p
                                    break
                                end
                            end
                        end
                        guia, principalViva = ancla, ancla and principalDe(ancla)
                        if exacta then
                            -- la pieza de verdad del mismo nombre ya se mueve como la de la skin: la
                            -- copia va justo encima. Si el arma no la tiene, se le arma su unión (y
                            -- si no hay pieza que la guíe, se ve cuando se ve el brazo de su lado).
                            if ancla and ancla.Name == piezaSkin.Name then
                                desfase = CFrame.new()
                            elseif not (contexto and not ancla) then
                                local propia = unionPropia(piezaSkin)
                                if propia then
                                    principalViva, desfase = propia, CFrame.new()
                                    guia = guia or vm:FindFirstChild(piezaSkin.Name:find("Left") and "LeftArm" or "RightArm")
                                end
                            end
                        end
                        if not desfase and ancla then desfase = ubicar(ancla, piezaSkin) end
                    end
                    if principalSkin and principalViva and guia and desfase then
                        local g = grupoDe(guia)
                        for _, d in ipairs(piezaSkin:GetDescendants()) do
                            local deLlavero = enLlavero(d, piezaSkin)
                            if d:IsA("BasePart") and d ~= principalSkin
                                and (not deLlavero or (conLlavero and d.Transparency < 1)) then
                                local relativo = principalSkin.CFrame:ToObjectSpace(d.CFrame)
                                local copia = d:Clone()
                                for _, x in ipairs(copia:GetDescendants()) do
                                    if x:IsA("BasePart") or x:IsA("JointInstance") or x:IsA("WeldConstraint") then
                                        x:Destroy()
                                    end
                                end
                                copia.Anchored = false
                                copia.CanCollide = false
                                copia.CanQuery = false
                                copia.CanTouch = false
                                copia.Massless = true
                                copia.CFrame = principalViva.CFrame * desfase * relativo
                                local union = Instance.new("Weld")
                                union.Part0 = principalViva
                                union.Part1 = copia
                                union.C0 = desfase * relativo
                                union.Parent = copia
                                copia.Parent = carpeta
                                if not copia:GetAttribute("GarraOrigen") then table.insert(g.cosas, copia) end
                                for _, x in ipairs(copia:GetDescendants()) do
                                    if x:IsA("Decal") then
                                        table.insert(g.cosas, x)
                                    elseif esEfecto(x) then
                                        g.efectos[x] = x.Enabled
                                    end
                                end
                                ponerWrap(copia, g)
                                -- lo que la skin esconde al sacarla (la hoja del Saber, hasta que se enciende)
                                local ocultar = EQUIPAR[skin.nombre] and EQUIPAR[skin.nombre].ocultar
                                if ocultar and (d.Name == ocultar or d:FindFirstAncestor(ocultar)) then
                                    table.insert(r.ocultables, { copia, g })
                                end
                            end
                        end
                    end
                end
            end
            carpeta.Parent = vm
            r.carpeta = carpeta

            -- Los puntos del cuerpo del arma (la mira, el cañón, el agarre...) van donde los tiene la
            -- skin: así al apuntar el juego alinea la mira de la skin, y el fogonazo sale de su cañón.
            local cuerpoVivo, cuerpoDeSkin = vivas.Body, skin.modelo:FindFirstChild("Body")
            local pv = cuerpoVivo and principalDe(cuerpoVivo)
            local ps = cuerpoDeSkin and principalDe(cuerpoDeSkin)
            if pv and ps then
                local desfaseCuerpo = exacta and CFrame.new() or ubicar(cuerpoVivo, cuerpoDeSkin)
                for _, a in ipairs(pv:GetChildren()) do
                    local suyo = a:IsA("Attachment") and a.Name:sub(1, 1) == "_" and ps:FindFirstChild(a.Name)
                    if suyo and suyo:IsA("Attachment") then
                        r.adjuntos[a] = a.CFrame
                        a.CFrame = desfaseCuerpo * suyo.CFrame
                    end
                end
            end
            -- (v6.20) skins propias con su propio cañón (las Desert Eagles): el fogonazo y las balas salen de su boca
            local propiaDef = PROPIAS[skin.nombre]
            if propiaDef and propiaDef.muzzle then
                for _, pieza in pairs(vivas) do
                    local pp = principalDe(pieza)
                    local boca = pp and pp:FindFirstChild("_muzzle")
                    if boca and boca:IsA("Attachment") then
                        r.adjuntos[boca] = r.adjuntos[boca] or boca.CFrame
                        boca.CFrame = CFrame.new(propiaDef.muzzle[1], propiaDef.muzzle[2], propiaDef.muzzle[3])
                    end
                end
            end
            if conLlavero then moverLlavero(r, piezaLlavero, skin.modelo:FindFirstChild(piezaLlavero.Name)) end

            -- el llavero con la opacidad (puede aparecer después que el arma)
            local function tomarLlavero(m)
                if not (m:IsA("Model") and m ~= item and m:FindFirstChild("_pivot_attachment", true)) then return end
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("BasePart") and not r.llavero[d] then
                        local e = { juego = d.LocalTransparencyModifier }
                        r.llavero[d] = e
                        table.insert(r.conexiones, d:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
                            local v = d.LocalTransparencyModifier
                            if e.puesto and math.abs(v - e.puesto) < 0.0005 then return end -- es lo nuestro
                            e.juego = v
                            atenuar(r, d)
                        end))
                        atenuar(r, d)
                    end
                end
            end
            for _, m in ipairs(vm:GetChildren()) do tomarLlavero(m) end
            table.insert(r.conexiones, vm.ChildAdded:Connect(function(m)
                task.defer(function()
                    if registro[vm] == r and m.Parent == vm then pcall(tomarLlavero, m) end
                end)
            end))

            if exacta then prepararAnimaciones(r, vm, cambios) end
            -- (v6.1) skins propias con animaciones de los brazos (las garras)
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].acciones then
                pcall(prepararGarras, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.28) el escudo del Capitán América: su inspección propia
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].escudo then
                pcall(GARRAS.escudo, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.55) la estela y la luz de una skin propia (la Death Sickle, la Terrambit)
            if PROPIAS[skin.nombre] and (PROPIAS[skin.nombre].estela or PROPIAS[skin.nombre].luz) then
                pcall(GARRAS.estela, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.80) el parlante: la mano izquierda toca un boton al usarlo
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].tocar then
                pcall(GARRAS.tocar, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.94) el parlante: silenciar el sonido del cuerno de verdad y latir al sonar
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].silenciarUso then
                pcall(GARRAS.silenciarUso, r, vm, skin, armaReal, skinReal)
            end
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].parlante then
                pcall(GARRAS.parlante, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.67) la mira de la SCAR: se centra la mirilla en el agujero
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].mira then
                pcall(GARRAS.mira, r, vm, skin, armaReal, skinReal)
            end
            -- (v6.66) la telaraña del lanzatelarañas (Grappler)
            if PROPIAS[skin.nombre] and PROPIAS[skin.nombre].telarana then
                pcall(GARRAS.telarana, r, vm, skin, armaReal, skinReal)
            end
            -- skin de la misma arma: cada animación suena con los sonidos de la skin, a su tiempo
            -- (aunque la animación sea la misma: la AKEY-47 solo cambia los sonidos)
            if mismaFamilia(armaDeLaSkin(skin), armaReal) then prepararTiempos(r, vm, skinReal or armaReal, skin.nombre) end
        elseif wrap then
            -- sin modelo en la biblioteca: el wrap va directo sobre las piezas de verdad
            for _, pieza in pairs(vivas) do
                local g = grupoDe(pieza)
                local principal = principalDe(pieza)
                for _, d in ipairs(pieza:GetDescendants()) do
                    if d:IsA("BasePart") and d ~= principal and not enLlavero(d, pieza) then
                        ponerWrap(d, g)
                    end
                end
            end
        end

        -- 3) cada grupo copia lo que el juego hace con su pieza, apenas cambia
        for _, g in ipairs(r.grupos) do
            aplicarVisibilidad(g)
            local function vigilar(parte, propiedad)
                if parte then
                    table.insert(r.conexiones, parte:GetPropertyChangedSignal(propiedad):Connect(function()
                        aplicarVisibilidad(g)
                    end))
                end
            end
            vigilar(principalDe(g.guia), "LocalTransparencyModifier")
            vigilar(g.testigo, "LocalTransparencyModifier")
            vigilar(g.testigo, "Transparency")
        end
    end

    -- Barra de armas (abajo a la derecha): la imagen de cada arma muestra la skin elegida

    local iconos = {} -- ImageLabel -> { juego = imagen del juego, puesta = la nuestra, con = conexión }

    local function contenedorBarra()
        local ok, contenedor = pcall(function()
            return jugador.PlayerGui.MainGui.MainFrame.FighterInterfaces[jugador.Name]
                .BottomRight.Container.Hotbar.Container
        end)
        return ok and contenedor or nil
    end

    local function devolverIcono(icono)
        local e = iconos[icono]
        if not e then return end
        iconos[icono] = nil
        e.con:Disconnect()
        pcall(function()
            icono.Image = e.juego
            icono.ScaleType = e.escala
            icono.ImageRectOffset = e.rp
            icono.ImageRectSize = e.rt
        end)
    end

    local function ponerIcono(icono, imagen)
        if not imagen then
            devolverIcono(icono)
            return
        end
        local e = iconos[icono]
        if not e then
            e = { juego = icono.Image, escala = icono.ScaleType, rp = icono.ImageRectOffset, rt = icono.ImageRectSize }
            iconos[icono] = e
            e.con = icono:GetPropertyChangedSignal("Image"):Connect(function()
                if icono.Image ~= e.puesta then
                    e.juego = icono.Image -- el juego la cambió (otra skin de verdad): se anota y va la nuestra
                    icono.Image = e.puesta
                end
            end)
        end
        e.puesta = imagen
        -- (v6.53) las miniaturas propias entran enteras (Fit); las imagenes del juego se dejan como las tenia el juego
        if IMAGEN_DE._propias and IMAGEN_DE._propias[imagen] then
            icono.ScaleType = Enum.ScaleType.Fit
            icono.ImageRectOffset = Vector2.new(0, 0)
            icono.ImageRectSize = Vector2.new(0, 0)
        else
            icono.ScaleType = e.escala
            icono.ImageRectOffset = e.rp
            icono.ImageRectSize = e.rt
        end
        if icono.Image ~= imagen then icono.Image = imagen end
    end

    local function revisarBarra()
        for icono in pairs(iconos) do
            if not icono.Parent then
                iconos[icono].con:Disconnect()
                iconos[icono] = nil
            end
        end
        local contenedor = contenedorBarra()
        if not contenedor then return end
        for _, marco in ipairs(contenedor:GetChildren()) do
            local icono = marco:FindFirstChild("Icon")
            if icono and icono:IsA("ImageLabel") then
                local clave = elecciones[marco.Name]
                local s = clave and porClave[clave]
                ponerIcono(icono, s and IMAGEN_DE[s.nombre])
            end
        end
    end

    -- Sonidos --------------------------------------------------------------------
    -- El juego crea un Sound nuevo por cada disparo/recarga con el id del sonido normal.
    -- Se silencia y en su lugar suenan los de la skin elegida.

    local mapaSonidos = {}  -- id del juego (texto) -> ids de la skin a tocar
    local ultimoUnico = setmetatable({}, { __mode = "k" }) -- cuándo sonó por última vez cada sonido "unico" (v5.8)
    local sonidoSacar = nil -- sonidos de sacar el arma (si el arma normal no tiene)
    local firmaSonidos = nil

    -- Sonidos con tiempos (v4.8). Cada animación de Rivals tiene su línea de tiempo (qué suena en
    -- qué segundo, skins_tiempos.lua) y el juego la corre cuando pone la animación. Como la del arma
    -- normal sigue corriendo debajo de la de la skin, sonaba la del arma normal (y la inspección de
    -- la Keyrambit, que no suena, sonaba como la del cuchillo). Ahora, por acción (tiemposEntre):
    --   id de la animación del juego -> { skin = eventos de la skin, callar = ids del juego que se
    --   callan, vol = su volumen en el módulo, largo = cuánto dura lo del juego, factor = velocidad
    --   de la skin / la del juego }
    local silencios = {}    -- ventanas: { ids, vol, hasta } mientras corre la línea del juego
    local recientes = {}    -- los sonidos del juego del último segundo: { s, id, t }
    local escalaVolumen = 1 -- el volumen que pone el juego / el de su módulo (su ajuste de sonido)

    local function tiemposEntre(real, elegida)
        local acciones = {}
        for _, nombre in ipairs({ real, elegida }) do
            local v = NOMBRES_ANIM[nombre]
            for accion in pairs(v or {}) do acciones[accion] = true end
            for accion in pairs(v and v._arma and NOMBRES_ANIM[v._arma] or {}) do acciones[accion] = true end
        end
        acciones._arma = nil
        local mapa, nombresJuego, equip = {}, {}, false
        for accion in pairs(acciones) do
            local idJuego, deJuego = animacionDe(real, accion), nombreAnim(real, accion)
            local deSkin, idSkin, otra = nombreAnim(elegida, accion), animacionDe(elegida, accion), accion
            while not deSkin and otra do
                otra = parecida(otra)
                deSkin = otra and nombreAnim(elegida, otra)
                idSkin = otra and animacionDe(elegida, otra) or idSkin
            end
            -- si la de la skin hace algo propio (elegir un sonido al azar...) no se toca
            local eventos = deSkin and TIEMPOS[deSkin]
            if idJuego and deJuego and deSkin ~= deJuego and eventos then
                local juego = TIEMPOS[deJuego]
                local callar, vol, largo = {}, {}, 0.5
                for _, ev in ipairs(juego or {}) do
                    local id = tostring(ev[2])
                    callar[id] = true
                    vol[id] = vol[id] or ev[3]
                    largo = math.max(largo, ev[1] + 0.5)
                end
                if not juego then -- la del juego hace algo propio: se callan los que tiene anotados
                    for _, id in ipairs(SONIDOS[deJuego] or {}) do callar[tostring(id)] = true end
                    largo = 8
                end
                mapa[idJuego] = {
                    skin = eventos, callar = callar, vol = vol, largo = largo,
                    factor = (VELOCIDADES[idSkin or idJuego] or 1) / (VELOCIDADES[idJuego] or 1),
                }
                nombresJuego[deJuego] = true
                if accion == "Equip" then equip = true end
            end
        end
        return mapa, nombresJuego, equip
    end

    -- Skins con su propio sonido de golpe (el "hitmarker", que suena al pegarle a alguien).
    -- Sacado de sus módulos en PlayerScripts.Modules.ViewModels (PlayHitmarkerSound). El normal
    -- del juego es 13110130082 con tono de 1 a 1,2; la skin usa el suyo con tono de "tono" a
    -- "tono" + 0,25. Los de la cabeza no cambian. solo = reemplaza al normal (si no, suena además).
    local GOLPE_JUEGO = "13110130082"
    local GOLPES = {
        ["Boxing Gloves"] = { id = 17650289572, tono = 1.25, solo = true },
        ["Fists of Hurt"] = { id = 88497957004619, tono = 0.75, solo = true },
        ["Clown Hammer"] = { id = 84868739299715, tono = 1 },
    }
    -- (v6.1) las skins propias pueden traer su sonido de golpe (un archivo)
    for nombre, def in pairs(PROPIAS) do
        if def.golpe then GOLPES[nombre] = { id = def.golpe.archivo, tono = def.golpe.tono or 1, solo = true } end
    end
    local golpeActual = nil -- el de la skin elegida para el arma en la mano (si tiene)

    -- Sonidos del módulo de cada skin (desviar con la katana, cargar el arco, el flashbang, el
    -- lanzallamas...): cuando el juego toca el suyo, suena el de la skin en su lugar o además.
    -- reglasModulo: id del juego (texto) -> { ids = de la skin, callar = si el del juego se calla }
    local reglasModulo = {}

    -- los ids de un método en el módulo de un arma o skin (o en el de su arma, si no lo cambia)
    local function sonidosDelModulo(nombre, metodo)
        local m, vueltas = MODULOS[nombre], 0
        while m and vueltas < 8 do
            if m.s and m.s[metodo] then return m.s[metodo] end
            m, vueltas = m.padre and MODULOS[m.padre], vueltas + 1
        end
        return nil
    end

    local function reglasEntre(real, elegida)
        local reglas, metodos = {}, {}
        for _, nombre in ipairs({ real, elegida }) do
            local m, vueltas = MODULOS[nombre], 0
            while m and vueltas < 8 do
                for metodo in pairs(m.s or {}) do metodos[metodo] = true end
                m, vueltas = m.padre and MODULOS[m.padre], vueltas + 1
            end
        end
        for metodo in pairs(metodos) do
            local deJuego, deSkin = sonidosDelModulo(real, metodo), sonidosDelModulo(elegida, metodo)
            if deJuego and deSkin and deJuego ~= deSkin then
                local enSkin, enJuego, cambiados, nuevos = {}, {}, {}, {}
                for _, id in ipairs(deSkin) do enSkin[id] = true end
                for _, id in ipairs(deJuego) do enJuego[id] = true end
                for _, id in ipairs(deJuego) do
                    if not enSkin[id] then table.insert(cambiados, id) end
                end
                for _, id in ipairs(deSkin) do
                    if not enJuego[id] then table.insert(nuevos, id) end
                end
                if #cambiados == 0 then
                    -- la skin suena además del juego: los suyos van con el primero del juego
                    if #nuevos > 0 then reglas[tostring(deJuego[1])] = { ids = nuevos, callar = false } end
                else
                    -- cada sonido del juego que la skin no usa se cambia por uno suyo; el último se
                    -- lleva los que sobren, y si no alcanzan se calla
                    for i, id in ipairs(cambiados) do
                        local ids = {}
                        if i < #cambiados then
                            ids = { nuevos[i] }
                        else
                            for j = i, #nuevos do table.insert(ids, nuevos[j]) end
                        end
                        reglas[tostring(id)] = { ids = ids, callar = true }
                    end
                end
            end
        end
        return reglas
    end

    -- El del juego se calla con un ecualizador a -80 dB (así su volumen lo sigue manejando el
    -- juego) y los de la skin lo imitan: suenan, se paran y cambian de volumen y tono con él.
    -- Sirve igual para los de un solo golpe y para los que el juego repite (el lanzallamas).
    local espejos = {} -- sonido del juego -> lo que se le hizo (para deshacerlo si cambia la skin)

    local function deshacerEspejo(original)
        local e = espejos[original]
        if not e then return end
        espejos[original] = nil
        for _, con in ipairs(e.cons) do con:Disconnect() end
        if e.silencio then pcall(function() e.silencio:Destroy() end) end
        for _, c in ipairs(e.copias) do pcall(function() c:Destroy() end) end
    end

    local function espejar(original, regla, recienCreado)
        if espejos[original] then return end
        local e = { copias = {}, cons = {} }
        espejos[original] = e
        for _, id in ipairs(regla.ids) do
            local c = Instance.new("Sound")
            c.SoundId = "rbxassetid://" .. tostring(id)
            c.Volume, c.PlaybackSpeed, c.Looped = original.Volume, original.PlaybackSpeed, original.Looped
            c.RollOffMode = original.RollOffMode
            c.RollOffMinDistance, c.RollOffMaxDistance = original.RollOffMinDistance, original.RollOffMaxDistance
            c:SetAttribute("CieloSonido", true)
            c.Parent = original.Parent
            table.insert(e.copias, c)
        end
        if regla.callar then
            e.silencio = crear("EqualizerSoundEffect", {
                Name = "CieloSilencio", LowGain = -80, MidGain = -80, HighGain = -80, Parent = original,
            })
        end
        local function todas(f)
            for _, c in ipairs(e.copias) do pcall(f, c) end
        end
        -- recién creado ya sonando (un golpe): los nuestros también; al revisar los que ya había, solo
        -- se prenden los que se repiten (para no volver a tocar un golpe que ya pasó)
        if original.IsPlaying and (recienCreado or original.Looped) then todas(function(c) c:Play() end) end
        table.insert(e.cons, original.Played:Connect(function()
            todas(function(c)
                c.TimePosition = 0
                c:Play()
            end)
        end))
        table.insert(e.cons, original.Stopped:Connect(function() todas(function(c) c:Stop() end) end))
        table.insert(e.cons, original.Paused:Connect(function() todas(function(c) c:Pause() end) end))
        table.insert(e.cons, original.Resumed:Connect(function() todas(function(c) c:Resume() end) end))
        for _, propiedad in ipairs({ "Volume", "PlaybackSpeed", "Looped" }) do
            table.insert(e.cons, original:GetPropertyChangedSignal(propiedad):Connect(function()
                todas(function(c) c[propiedad] = original[propiedad] end)
            end))
        end
        -- cuando el juego lo quita: los que se repetían se van con él; los de un golpe terminan solos
        -- (ver más abajo aplicarReglasAVivos: los que ya estaban al cambiar de skin)
        table.insert(e.cons, original.AncestryChanged:Connect(function(_, padre)
            if padre then return end
            espejos[original] = nil
            for _, con in ipairs(e.cons) do con:Disconnect() end
            todas(function(c)
                if original.Looped or not c.IsPlaying then
                    c:Destroy()
                else
                    c.Ended:Connect(function() c:Destroy() end)
                    task.delay(15, function()
                        if c.Parent then c:Destroy() end
                    end)
                end
            end)
        end))
    end

    local function prefijoDe(w, nombreSkin)
        local candidatos = { norm(nombreSkin) }
        if ANTIGUOS[nombreSkin] then table.insert(candidatos, norm(ANTIGUOS[nombreSkin])) end
        for _, k in ipairs(candidatos) do
            local p = w .. "_" .. k .. "_"
            for n in pairs(SONIDOS) do
                if n:sub(1, #p) == p then return p end
            end
        end
        return nil
    end

    -- al cambiar de arma o de skin, los sonidos que el juego ya había creado también se cambian
    -- (los que repite, como el del lanzallamas, los crea al sacar el arma)
    local function aplicarReglasAVivos()
        local raices = {}
        local function sumar(x)
            if x then table.insert(raices, x) end
        end
        local scripts = jugador:FindFirstChild("PlayerScripts")
        sumar(scripts and scripts:FindFirstChild("Modules"))
        sumar(jugador.Character)
        local vms = workspace:FindFirstChild("ViewModels")
        sumar(vms and vms:FindFirstChild("FirstPerson"))
        for _, raizSonidos in ipairs(raices) do
            for _, s in ipairs(raizSonidos:GetDescendants()) do
                if s:IsA("Sound") and not s:GetAttribute("CieloSonido") then
                    local regla = reglasModulo[tostring(s.SoundId):match("%d+") or ""]
                    if regla then espejar(s, regla, false) end
                end
            end
        end
    end

    local function prepararSonidos(arma, skinReal, skinElegida)
        mapaSonidos = {}
        sonidoSacar = nil
        golpeActual = nil
        -- (v6.7) el golpe que hace el juego con la skin de verdad (Boxing Gloves suena distinto al golpe de siempre)
        GARRAS.golpeReal = skinReal and GOLPES[skinReal] and tostring(GOLPES[skinReal].id) or nil
        reglasModulo = {}
        table.clear(silencios)
        local viejos = {}
        for original in pairs(espejos) do table.insert(viejos, original) end
        for _, original in ipairs(viejos) do deshacerEspejo(original) end
        if not (sonidosActivos and arma and skinElegida) then return end
        if skinReal and norm(skinElegida) == norm(skinReal) then return end
        golpeActual = GOLPES[skinElegida]
        reglasModulo = reglasEntre(skinReal or arma, skinElegida)
        if next(reglasModulo) then pcall(aplicarReglasAVivos) end
        -- skin de la misma arma: las acciones con línea de tiempo van por ahí (prepararTiempos);
        -- lo de abajo (cambiar cada sonido por otro al mismo tiempo) queda para el resto
        local nombresConTiempos, equipConTiempos = {}, false
        local armaElegida = ARMA_DE[skinElegida] or (VISTAS[skinElegida] and VISTAS[skinElegida]._arma) or skinElegida
        if mismaFamilia(armaElegida, arma) then
            local _
            _, nombresConTiempos, equipConTiempos = tiemposEntre(skinReal or arma, skinElegida)
        end
        local w = norm(arma)
        -- los sonidos de la skin se buscan con su arma de verdad (puede ser de otra arma)
        local armaSkin = ARMA_DE[skinElegida] and norm(ARMA_DE[skinElegida]) or w
        local prefijoSkin = prefijoDe(armaSkin, skinElegida) or prefijoDe(w, skinElegida)
        if not prefijoSkin then return end
        local prefijoReal = skinReal and norm(skinReal) ~= w and prefijoDe(w, skinReal) or nil

        local acciones = {}
        for n, idsSkin in pairs(SONIDOS) do
            if n:sub(1, #prefijoSkin) == prefijoSkin then
                table.insert(acciones, { nombre = n:sub(#prefijoSkin + 1), ids = idsSkin })
            end
        end
        -- si un sonido se repite entre acciones, manda la más común: disparo > recarga > el resto
        local function esDisparo(a) return a:find("shoot") ~= nil or a:find("attack") ~= nil end
        local function prioridad(a)
            if esDisparo(a) then return 0 end
            if a:find("reload") then return 1 end
            return 2
        end
        table.sort(acciones, function(a, b)
            local pa, pb = prioridad(a.nombre), prioridad(b.nombre)
            if pa ~= pb then return pa < pb end
            return a.nombre < b.nombre
        end)

        for _, accion in ipairs(acciones) do
            local nombreJuego = (prefijoReal and SONIDOS[prefijoReal .. accion.nombre]) and (prefijoReal .. accion.nombre)
                or (w .. "_" .. accion.nombre)
            local idsJuego = not nombresConTiempos[nombreJuego] and SONIDOS[nombreJuego]
            if nombresConTiempos[nombreJuego] or (accion.nombre == "equip" and equipConTiempos) then
                -- esta acción ya suena con su línea de tiempo
            elseif idsJuego then
                local n, m = #idsJuego, #accion.ids
                for i, id in ipairs(idsJuego) do
                    local clave = tostring(id)
                    -- (v6.52) accion.ids.solo: la skin propia cambia solo esos ids del juego (la Pump Shotgun: los estampidos, no el bombeo)
                    if not mapaSonidos[clave] and not (accion.ids.solo and not accion.ids.solo[id]) then
                        local tocarIds = {}
                        -- (v6.81) accion.ids.unico (los sonidos propios que se alternan: el parlante) tambien se pasa entero: si se repartian como los de una
                        -- recarga, los 6 sonaban juntos en un solo sonido en vez de elegir uno al azar
                        if esDisparo(accion.nombre) or accion.ids.unico then
                            tocarIds = accion.ids
                        else
                            -- recargas e inspecciones: se reparten en el mismo orden
                            for j = math.floor((i - 1) * m / n) + 1, math.floor(i * m / n) do
                                table.insert(tocarIds, accion.ids[j])
                            end
                        end
                        if #tocarIds > 0 then mapaSonidos[clave] = tocarIds end
                    end
                end
            elseif accion.nombre == "equip" then
                sonidoSacar = accion.ids
            end
        end
    end

    -- (v5.8) un sonido es un id del juego o un archivo propio ("archivo:mac10_disparo.mp3", en la carpeta de Cielo)
    local function sonidoDe(id)
        if type(id) == "string" and id:sub(1, 8) == "archivo:" then
            -- (v6.9) getcustomasset tarda (copia el archivo): una vez por archivo
            local guardado = GARRAS.assets[id]
            if guardado then return guardado end
            local ok, asset = pcall(cargarAsset, ruta(id:sub(9)))
            if ok and type(asset) == "string" and asset ~= "" then
                GARRAS.assets[id] = asset
                return asset
            end
            return ""
        end
        return "rbxassetid://" .. tostring(id)
    end

    local function tocar(ids, parecido, padre)
        for _, id in ipairs(ids) do
            local s = Instance.new("Sound")
            s.SoundId = sonidoDe(id)
            s.Volume = parecido and parecido.Volume or 0.5
            s.PlaybackSpeed = parecido and parecido.PlaybackSpeed or 1
            s:SetAttribute("CieloSonido", true)
            s.Parent = padre or SoundService
            s:Play()
            s.Ended:Connect(function() s:Destroy() end)
            task.delay(15, function()
                if s.Parent then s:Destroy() end
            end)
        end
    end
    tocarArchivo = tocar -- (v6.1) para las garras (se definió antes, más arriba)

    -- (v6.9) los sonidos propios se preparan al cargar el script (si no, el primero que suena congela el juego un momento)
    task.spawn(function()
        task.wait(1)
        local archivos = {}
        local function ver(v)
            if type(v) == "string" and v:sub(1, 8) == "archivo:" then archivos[v] = true end
        end
        for _, def in pairs(PROPIAS) do
            for _, s in pairs(def.sonidos or {}) do
                if type(s) == "table" then
                    ver(s.archivo)
                    for _, x in ipairs(s) do ver(x) end
                end
            end
            if def.golpe then ver(def.golpe.archivo) end
        end
        for id in pairs(archivos) do
            pcall(function()
                local s = Instance.new("Sound")
                s.SoundId = sonidoDe(id)
                game:GetService("ContentProvider"):PreloadAsync({ s })
                s:Destroy()
            end)
            task.wait(0.3)
        end
    end)

    -- un sonido de la línea de tiempo del juego: se calla (ecualizador a -80 dB, como en espejar) y,
    -- con su volumen en el módulo, se anota cuánto le sube o baja el juego (su ajuste de volumen)
    local function callarSonido(s, nominal)
        crear("EqualizerSoundEffect", {
            Name = "CieloSilencio", LowGain = -80, MidGain = -80, HighGain = -80, Parent = s,
        })
        if nominal and nominal > 0 then
            task.defer(function()
                local razon = s.Volume / nominal
                if razon >= 0.2 and razon <= 5 then escalaVolumen = razon end
            end)
        end
    end

    -- Cuando el juego pone una animación de una acción que en la skin suena distinto: se callan los
    -- suyos mientras dura su línea de tiempo y suena la de la skin, a la velocidad de la animación
    -- de la skin (la misma con la que la pone prepararAnimaciones). Si el juego la corta antes de
    -- terminar (atacar en plena inspección), se cortan también; si terminó sola, la de la skin
    -- puede seguir hasta su final, como su animación.
    prepararTiempos = function(r, vm, real, elegida)
        local animator = vm:FindFirstChildWhichIsA("Animator", true)
        if not animator then return end
        local mapa = tiemposEntre(real, elegida)
        if not next(mapa) then return end
        local hilos, vigiladas = {}, {}
        local function correr(g, e, desde)
            if hilos[g] then pcall(task.cancel, hilos[g]) end
            local velocidad = math.max(g.Speed, 0.05)
            local inicio = os.clock() - desde
            table.insert(silencios, { ids = e.callar, vol = e.vol, hasta = inicio + e.largo / velocidad })
            -- lo del juego que alcanzó a empezar antes (al sacar el arma, mi revisión llega un poco
            -- después): se calla igual
            if desde > 0 then
                for _, x in ipairs(recientes) do
                    if x.t >= inicio - 0.1 and e.callar[x.id] and x.s.Parent and not x.s:FindFirstChild("CieloSilencio") then
                        pcall(callarSonido, x.s, e.vol[x.id])
                    end
                end
            end
            local vSkin = velocidad * e.factor
            hilos[g] = task.spawn(function()
                for _, ev in ipairs(e.skin) do
                    local cuando = inicio + ev[1] / vSkin
                    -- lo que ya pasó cuando se vistió el arma suena igual si fue hace poco (un sonido
                    -- un poco tarde se nota menos que uno que falta); lo de antes, no
                    if cuando >= inicio + desde - 0.35 then
                        local falta = cuando - os.clock()
                        if falta > 0 then task.wait(falta) end
                        if not vivo or registro[vm] ~= r or not sonidosActivos then return end
                        tocar({ ev[2] }, {
                            Volume = (ev[3] + (ev[6] or 0) * math.random()) * escalaVolumen,
                            PlaybackSpeed = ev[4] + (ev[5] or 0) * math.random(),
                        })
                    end
                end
                hilos[g] = nil
            end)
            if not vigiladas[g] then
                vigiladas[g] = true
                table.insert(r.conexiones, g.Stopped:Connect(function()
                    local termino = not g.Looped and g.Length > 0 and g.TimePosition >= g.Length - 0.06
                    if not termino and hilos[g] then
                        pcall(task.cancel, hilos[g])
                        hilos[g] = nil
                    end
                end))
            end
        end
        local function entrada(g)
            if propias[g] or not sonidosActivos then return nil end
            local id = g.Animation and tonumber(g.Animation.AnimationId:match("%d+"))
            return id and mapa[id]
        end
        table.insert(r.conexiones, animator.AnimationPlayed:Connect(function(g)
            if propias[g] then return end
            -- una acción nueva corta lo que había quedado sonando de una que ya terminó (como hace
            -- prepararAnimaciones con su animación)
            for otra, hilo in pairs(hilos) do
                if otra ~= g and not otra.IsPlaying then
                    pcall(task.cancel, hilo)
                    hilos[otra] = nil
                end
            end
            local e = entrada(g)
            if e then pcall(correr, g, e, 0) end
        end))
        -- la que ya estaba sonando al vestirla (la de sacar el arma, casi siempre): desde donde va
        for _, g in ipairs(animator:GetPlayingAnimationTracks()) do
            local e = entrada(g)
            if e and g.TimePosition < 1.5 then pcall(correr, g, e, g.TimePosition / math.max(g.Speed, 0.05)) end
        end
    end

    local function alCrearSonido(s)
        if s:GetAttribute("CieloSonido") then return end
        local id = tostring(s.SoundId):match("%d+")
        local ahora = os.clock()
        if id then
            while recientes[1] and ahora - recientes[1].t > 1 do table.remove(recientes, 1) end
            table.insert(recientes, { s = s, id = id, t = ahora })
        end
        -- (v6.94) el parlante: mientras dura el uso del cuerno, el primer sonido nuevo del juego bajo PlayerScripts (sea cual sea su id: el del cuerno de verdad se colaba a veces
        -- porque su id no estaba en la lista) se cambia por uno de los troll y todos los demas se callan
        local uso = GARRAS.usoActivo
        local forzado = nil
        if uso and ahora < uso.hasta and s:IsDescendantOf(jugador.PlayerScripts) then
            if uso.sono then
                s.Volume = 0
                return
            end
            uso.sono = true
            forzado = uso.ids
            GARRAS.anotar("uso del parlante: el sonido del juego " .. tostring(id) .. " en " .. s:GetFullName() .. " se cambia por un troll")
        end
        -- lo que toca la línea de tiempo del juego mientras suena la de la skin: se calla
        if id and #silencios > 0 then
            for i = #silencios, 1, -1 do
                local v = silencios[i]
                if ahora > v.hasta then
                    table.remove(silencios, i)
                elseif v.ids[id] then
                    callarSonido(s, v.vol[id])
                    return
                end
            end
        end
        if id == GOLPE_JUEGO or id == GARRAS.golpeReal then
            GARRAS.anotar("golpe del juego " .. id .. ": " .. (golpeActual and "lo cambio por el de la skin" or "golpeActual=nil, no se cambia"))
        end
        if (id == GOLPE_JUEGO or id == GARRAS.golpeReal) and golpeActual then
            -- el golpe de la skin, con el tono al azar del juego pasado a su rango
            local azar = math.clamp((s.PlaybackSpeed - 1) / 0.2, 0, 1)
            local copia = { Volume = s.Volume, PlaybackSpeed = golpeActual.tono + 0.25 * azar }
            if golpeActual.solo then s.Volume = 0 end
            tocar({ golpeActual.id }, copia, s.Parent)
            return
        end
        local regla = id and reglasModulo[id]
        if regla then
            espejar(s, regla, true)
            return
        end
        local ids = forzado or (id and mapaSonidos[id])
        if not ids then return end
        local copia = { Volume = s.Volume, PlaybackSpeed = s.PlaybackSpeed }
        s.Volume = 0
        if ids.unico then
            -- (v5.8) skin propia: el juego crea varias capas por disparo a la vez; el sonido propio suena una sola
            -- vez, con su volumen (el de las capas del juego varía mucho)
            local ahora = os.clock()
            if ahora - (ultimoUnico[ids] or -1) < 0.045 then return end -- (el Uzi dispara cada 0.07 s: tiene que ser menos)
            ultimoUnico[ids] = ahora
            -- (v6.94) el parlante late mientras suena (conos, aros de luz y notas)
            if ids.latido and GARRAS.latidoParlante then pcall(GARRAS.latidoParlante, 2.4) end
            copia.Volume = ids.vol or copia.Volume
            -- (v6.79) cada disparo con un volumen un poco distinto (volazar = fraccion: 0.12 = +-12 %)
            if ids.volazar then copia.Volume = copia.Volume * (1 + ids.volazar * (math.random() * 2 - 1)) end
            -- (v6.80) retraso: el sonido suena unos segundos despues de que el juego lo pide (el parlante: cuando la mano toca el boton)
            local retraso = ids.retraso
            -- (v6.18) el tono tampoco se toma del juego: cada capa de un disparo trae el suyo (0.6 a 1.5) y según cuál
            -- llegara primero el disparo sonaba largo y grave o corto y seco; ahora es fijo (con un poquito de variación)
            if ids.tono then copia.PlaybackSpeed = ids.tono + (ids.azar or 0) * (math.random() * 2 - 1) end
            -- (v6.36) varios disparos grabados (la SCAR): suena uno al azar, nunca el mismo dos veces seguidas
            if ids.alternar and #ids > 1 then
                local i = math.random(#ids - 1)
                if ids.ultimo and i >= ids.ultimo then i = i + 1 end
                ids.ultimo = i
                if retraso then
                    local padre = s.Parent
                    task.delay(retraso, function() pcall(tocar, { ids[i] }, copia, padre) end)
                else
                    tocar({ ids[i] }, copia, s.Parent)
                end
                return
            end
        end
        tocar(ids, copia, s.Parent)
    end

    -- sonidos nuevos del jugador (disparos, recargas...): en PlayerScripts, en tu personaje y en
    -- el arma en la mano (esa se vigila en revisar, cuando aparece su carpeta)
    local function vigilarSonidos(raizSonidos)
        table.insert(conexionesUI, raizSonidos.DescendantAdded:Connect(function(d)
            if d:IsA("Sound") then pcall(alCrearSonido, d) end
        end))
    end
    vigilarSonidos(jugador:WaitForChild("PlayerScripts"))
    if jugador.Character then vigilarSonidos(jugador.Character) end
    table.insert(conexionesUI, jugador.CharacterAdded:Connect(vigilarSonidos))

    -- lo que hace la skin al sacarla (el Saber enciende su hoja, el Cerulean Axe...)
    local function efectoSacar(vm, arma, real)
        local clave = elecciones[arma]
        local s = clave and porClave[clave]
        local efecto = s and EQUIPAR[s.nombre]
        if not (sonidosActivos and efecto) or (real and norm(real) == norm(s.nombre)) then return end
        local r = registro[vm]
        local ultima = 0
        for _, paso in ipairs(efecto) do
            ultima = math.max(ultima, paso.espera)
            task.delay(paso.espera, function()
                if vivo and vm.Parent then
                    tocar({ paso.id }, { Volume = paso.volumen, PlaybackSpeed = paso.tono + (paso.azar or 0) * math.random() })
                end
            end)
        end
        if r and #r.ocultables > 0 then
            for _, par in ipairs(r.ocultables) do
                pcall(function() par[1].LocalTransparencyModifier = 1 end)
            end
            task.delay(ultima, function()
                if registro[vm] ~= r then return end
                for _, par in ipairs(r.ocultables) do
                    pcall(function() par[1].LocalTransparencyModifier = par[2].v or 0 end)
                end
            end)
        end
    end

    -- Vista previa 3D -------------------------------------------------------------

    -- la muestra plana de un wrap (sus capas de dibujo, repetidas como en el arma)
    local function dibujarMuestra(w, marco, escala)
        if w.material then
            -- wrap de material: una franja por ranura, con su color (y su transparencia, sin pasarse
            -- para que se vea algo)
            local n = 0
            for _, ranura in ipairs(w.ranuras) do
                if ranura then n = n + 1 end
            end
            local i = 0
            for _, ranura in ipairs(w.ranuras) do
                if ranura then
                    i = i + 1
                    local c = ranura.c or { 190, 190, 190 }
                    crear("Frame", {
                        Position = UDim2.fromScale((i - 1) / n, 0), Size = UDim2.fromScale(1 / n, 1), BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(c[1], c[2], c[3]),
                        BackgroundTransparency = math.min(ranura.t or 0, 0.6), ZIndex = 2, Parent = marco,
                    })
                end
            end
            return
        end
        for i, capa in ipairs(capasDe(w)) do
            local imagen = crear("ImageLabel", {
                Image = capa.imagen, ImageColor3 = capa.color, ImageTransparency = capa.transparencia,
                BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = i + 1,
                ScaleType = capa.baldosa and Enum.ScaleType.Tile or Enum.ScaleType.Crop, Parent = marco,
            })
            if capa.baldosa then
                imagen.TileSize = UDim2.fromOffset(
                    math.max(6, capa.baldosa.X * escala), math.max(6, capa.baldosa.Y * escala))
            end
        end
    end

    -- el arma armada tal como está en la biblioteca (con el cuerpo al centro y derecho),
    -- sin las piezas que solo salen al recargar
    local function armarModelo(s, wrap, recoger)
        local modelo = Instance.new("Model")
        local cuerpo = s.modelo:FindFirstChild("Body")
        local centro = cuerpo and principalDe(cuerpo)
        for _, pieza in ipairs(s.modelo:GetChildren()) do
            if pieza:IsA("Model") and pieza.Name ~= "_charm_attachment_model"
                and pieza:GetAttribute("AnimationContexts") == nil then
                local principal = principalDe(pieza)
                for _, d in ipairs(pieza:GetDescendants()) do
                    if d:IsA("BasePart") and d ~= principal and d.Transparency < 0.99 and not enLlavero(d, pieza) then
                        local copia = d:Clone()
                        for _, x in ipairs(copia:GetDescendants()) do
                            if x:IsA("BasePart") or x:IsA("JointInstance") or x:IsA("WeldConstraint") or esEfecto(x)
                                or x:IsA("Sound") or x:IsA("LuaSourceContainer") then
                                x:Destroy()
                            end
                        end
                        copia.Anchored = true
                        if centro then copia.CFrame = centro.CFrame:ToObjectSpace(d.CFrame) end
                        if wrap then ponerWrapEn(copia, wrap, recoger) end
                        copia.Parent = modelo
                    end
                end
            end
        end
        return modelo
    end

    -- Página SKINS / WRAPS ---------------------------------------------------------
    -- arriba el arma en la mano y lo puesto; en el medio la vista 3D de la que tienes el
    -- mouse encima (o de la que tienes puesta); abajo las tarjetas (skins o wraps)

    local armaActual, skinRealActual = nil, nil
    local mostrarTodas = false
    local tarjetas = {}
    local modoMostrado = nil
    local acomodarSkins -- (v6.92) pone cada cosa de la pagina en su lugar segun el ancho (se arma mas abajo)

    local function modo()
        return paginaActual == "wraps" and "wraps" or "skins"
    end

    -- la skin que se ve en el arma (la elegida, la de verdad o la del arma normal)
    local function skinMostrada(arma, real)
        local clave = arma and elecciones[arma]
        return (clave and porClave[clave]) or porNombre[real or ""] or (arma and porNombre[arma]) or nil
    end

    local avisoRivals = crear("TextLabel", {
        Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = C.tenue,
        TextWrapped = true, BackgroundTransparency = 1, Parent = paginaSkins,
        Text = "SKINS y WRAPS funcionan solo en Rivals.\nSi estás en Rivals, espera unos segundos a que cargue.",
    })
    local contenido = crear("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = paginaSkins,
    })

    local etiquetaArma = crear("TextLabel", {
        Size = UDim2.new(1, -176, 0, 28), Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = C.texto,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1, Text = "", Parent = contenido,
    })
    -- todas las armas como estaban: sin skins, sin wraps y con opacidad 100 (se conecta más abajo)
    local botonTodoOriginal = crear("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2), Size = UDim2.fromOffset(160, 26),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = "🔄  Todas como estaban", AutoButtonColor = false,
        BackgroundColor3 = C.panel, TextColor3 = C.texto, Parent = contenido,
    }, { esquina(13), trazo(Color3.fromRGB(255, 120, 140), 1, 0.4) })

    -- (v6.92, rediseno C) arriba a la derecha de la vista: lo puesto, la opacidad, ORIGINAL / INVERTIDO y los sonidos (un contenedor sin fondo; acomodarSkins lo pone)
    local filaPuesta = crear("Frame", {
        Position = UDim2.fromOffset(264, 32), Size = UDim2.fromOffset(300, 146), BackgroundTransparency = 1,
        Parent = contenido,
    })
    local etiquetaPuesta = crear("TextLabel", {
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamMedium,
        TextSize = 13, TextColor3 = C.tenue, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Text = "", Parent = filaPuesta,
    })
    local botonOriginal = crear("TextButton", {
        Position = UDim2.fromOffset(0, 68), Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = "ORIGINAL", TextColor3 = C.texto,
        BackgroundColor3 = C.panel2, AutoButtonColor = false, Parent = filaPuesta,
    }, { esquina(12) })
    local botonInvertido = crear("TextButton", { -- (v6.17) solo en WRAPS
        Position = UDim2.new(0.5, 4, 0, 68), Size = UDim2.new(0.5, -4, 0, 32),
        Font = Enum.Font.GothamBold, TextSize = 12, Text = "INVERTIDO: NO", TextColor3 = C.tenue,
        BackgroundColor3 = C.panel2, AutoButtonColor = false, Visible = false, Parent = filaPuesta,
    }, { esquina(12) })

    -- en el medio la vista 3D a lo ancho (lo que tienes bajo el mouse, o lo que tienes puesto);
    -- abajo el buscador y las tarjetas
    local panelVista = crear("Frame", {
        Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(250, 178),
        BackgroundColor3 = C.panel, Parent = contenido,
    }, { esquina(20), trazo(C.linea, 1, 0) })
    local visor = crear("ViewportFrame", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12),
        BackgroundColor3 = C.oscuro, BorderSizePixel = 0,
        Ambient = Color3.fromRGB(150, 145, 165), LightColor = Color3.fromRGB(255, 250, 245),
        LightDirection = Vector3.new(0.6, -1, 0.4), Parent = panelVista,
    }, { esquina(15) })
    local muestraGrande = crear("Frame", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12), Visible = false,
        BackgroundColor3 = C.oscuro, BorderSizePixel = 0, ClipsDescendants = true, Parent = panelVista,
    }, { esquina(15) })
    local camaraVista = Instance.new("Camera")
    camaraVista.FieldOfView = 30
    camaraVista.Parent = visor
    visor.CurrentCamera = camaraVista
    local infoVista = crear("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -12), Size = UDim2.new(1, -24, 0, 46),
        BackgroundColor3 = C.fondo, BackgroundTransparency = 0.2, ZIndex = 3, Parent = panelVista,
    }, { esquina(10) })
    local tituloVista = crear("TextLabel", {
        Position = UDim2.fromOffset(12, 5), Size = UDim2.new(1, -24, 0, 20),
        Text = "", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.texto, ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1, Parent = infoVista,
    })
    local detalleVista = crear("TextLabel", {
        Position = UDim2.fromOffset(12, 25), Size = UDim2.new(1, -24, 0, 15),
        Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.tenue, ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1, Parent = infoVista,
    })
    local botonSonidos = crear("TextButton", {
        Position = UDim2.fromOffset(0, 108), Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false, Text = "", ZIndex = 3,
        Parent = filaPuesta,
    }, { esquina(12), trazo(C.acento, 1, 0.5) })

    -- OPACIDAD de lo que tienes puesto en el arma (arriba a la izquierda de la vista): se
    -- arrastra la barrita; en 0% el arma no se ve
    local pildoraOpacidad = crear("Frame", {
        Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 34), ZIndex = 3,
        BackgroundColor3 = C.panel, Parent = filaPuesta,
    }, { esquina(12), trazo(C.linea, 1, 0) })
    crear("TextLabel", {
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0, 62, 1, 0), Text = "Opacidad",
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.tenue, ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = pildoraOpacidad,
    })
    local valorOpacidad = crear("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 40, 1, 0),
        Text = "100%", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.acento, ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = pildoraOpacidad,
    })
    local zonaOpacidad = crear("TextButton", { -- donde se agarra (más alta que la barrita)
        Position = UDim2.fromOffset(80, 0), Size = UDim2.new(1, -136, 1, 0), Text = "",
        BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 4, Parent = pildoraOpacidad,
    })
    local pistaOpacidad = crear("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = C.panel2, BorderSizePixel = 0, ZIndex = 4, Parent = zonaOpacidad,
    }, { crear("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local llenoOpacidad = crear("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 5,
        Parent = pistaOpacidad,
    }, {
        crear("UICorner", { CornerRadius = UDim.new(1, 0) }),
        crear("UIGradient", { Color = ColorSequence.new(C.acento, C.durazno) }),
    })
    local perillaOpacidad = crear("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = C.texto, ZIndex = 6, Parent = pistaOpacidad,
    }, { crear("UICorner", { CornerRadius = UDim.new(1, 0) }), trazo(C.oscuro, 2, 0) })
    local arrastrandoOpacidad = false

    local function pintarOpacidad(valor)
        llenoOpacidad.Size = UDim2.fromScale(valor / 100, 1)
        perillaOpacidad.Position = UDim2.fromScale(valor / 100, 0.5)
        valorOpacidad.Text = valor .. "%"
    end

    local cajaBuscar = crear("TextBox", {
        Position = UDim2.fromOffset(0, 190), Size = UDim2.new(1, -270, 0, 36), BackgroundColor3 = C.panel,
        TextColor3 = C.texto, PlaceholderText = "Buscar...", PlaceholderColor3 = C.tenue,
        Font = Enum.Font.Gotham, TextSize = 14, Text = "", ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = contenido,
    }, { esquina(18), trazo(C.linea, 1, 0), crear("UIPadding", { PaddingLeft = UDim.new(0, 16) }) })

    -- ESTA ARMA / TODAS (solo en SKINS)
    local filtro = crear("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 190), Size = UDim2.fromOffset(262, 36),
        BackgroundColor3 = C.panel, Parent = contenido,
    }, { esquina(18), trazo(C.linea, 1, 0) })
    local function botonFiltro(texto, i) -- (v6.92) tres: ESTA ARMA / TODAS / PROPIAS
        return crear("TextButton", {
            Position = UDim2.new(i / 3, i == 0 and 4 or 2, 0, 4), Size = UDim2.new(1 / 3, -5, 1, -8),
            Font = Enum.Font.GothamBold, TextSize = 11, Text = texto, AutoButtonColor = false,
            BackgroundColor3 = C.acento, Parent = filtro,
        }, { esquina(14) })
    end
    local botonEstaArma = botonFiltro("ESTA ARMA", 0)
    local botonTodas = botonFiltro("TODAS", 1)
    MINI.bProp = botonFiltro("PROPIAS", 2) -- las que hice yo (no vienen del juego)

    local lista = crear("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 236), Size = UDim2.new(1, 0, 1, -236),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 5,
        ScrollBarImageColor3 = C.acento, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = contenido,
    }, {
        crear("UIPadding", {
            PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 3),
        }),
        crear("UIGridLayout", {
            CellSize = UDim2.fromOffset(120, 132), CellPadding = UDim2.fromOffset(8, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local vacio = crear("TextLabel", {
        Position = UDim2.fromOffset(0, 246), Size = UDim2.new(1, 0, 0, 90), BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.tenue, TextWrapped = true, Text = "",
        Parent = contenido,
    })

    local modeloVista, centroVista, tamVista, claveVista, giro = nil, nil, nil, nil, nil
    local girar -- más abajo: hace girar la vista mientras se ve la página

    -- la cámara mira el arma de costado (el cañón hacia la izquierda, como en la barra de armas)
    local function encuadrar()
        if not (modeloVista and centroVista and tamVista) then return end
        local ancho, alto = visor.AbsoluteSize.X, visor.AbsoluteSize.Y
        local aspecto = alto > 0 and ancho / alto or 2.5
        local tanV = math.tan(math.rad(camaraVista.FieldOfView / 2))
        local largo = math.max(tamVista.Z, tamVista.X)
        local d = math.max((tamVista.Y / 2) / tanV, (largo / 2) / (tanV * aspecto)) * 1.12 + tamVista.X / 2
        camaraVista.CFrame = CFrame.lookAt(centroVista + Vector3.new(-d, d * 0.1, 0), centroVista)
    end
    table.insert(conexionesUI, visor:GetPropertyChangedSignal("AbsoluteSize"):Connect(encuadrar))

    -- la vista también muestra la opacidad
    local transparenciasVista = nil -- parte o calcomanía de la vista -> su transparencia de siempre (se arma solo si hace falta)
    local opacidadVista, opacidadAplicada = 1, 1
    -- (v6.12) las skins propias (de cientos de partes) se arman UNA vez: armarlas de nuevo cada vez que se cambia de arma o se
    -- pasa el mouse por la tarjeta congelaba el juego más de 1 s (la API del ejecutor es lenta)
    local cacheVista = {} -- clave -> { modelo, centro, tam, transp, op }
    local function opacarVista()
        if opacidadAplicada == opacidadVista or not modeloVista then return end
        if not transparenciasVista then
            transparenciasVista = {}
            for _, x in ipairs(modeloVista:GetDescendants()) do
                if x:IsA("BasePart") or x:IsA("Decal") then transparenciasVista[x] = x.Transparency end
            end
        end
        opacidadAplicada = opacidadVista
        for x, t in pairs(transparenciasVista) do
            x.Transparency = 1 - (1 - t) * opacidadVista
        end
    end

    local function limpiarVisor()
        if modeloVista then
            local guardada = claveVista and cacheVista[claveVista]
            if guardada then
                guardada.transp, guardada.op = transparenciasVista, opacidadAplicada
                modeloVista.Parent = nil
            else
                modeloVista:Destroy()
            end
            modeloVista = nil
        end
        MINI.visor = nil
        transparenciasVista = nil
        for _, h in ipairs(muestraGrande:GetChildren()) do
            if h:IsA("ImageLabel") then h:Destroy() end
        end
        muestraGrande.Visible = false
        claveVista = nil
    end

    -- s: la skin a mostrar en 3D (nil = solo la muestra plana del wrap); w: el wrap encima;
    -- opacidad: de 0 a 100 (si falta, 100)
    local function mostrarEnVisor(s, w, titulo, detalle, opacidad)
        tituloVista.Text = titulo or ""
        detalleVista.Text = detalle or ""
        opacidadVista = (opacidad or 100) / 100
        local clave = (s and s.clave or "-") .. "|" .. (w and w.nombre or "-") .. (w and w.invertido and "|inv" or "")
        if clave == claveVista then
            opacarVista()
            return
        end
        limpiarVisor()
        claveVista = clave
        local guardada = cacheVista[clave]
        -- (v6.17) las texturas de un wrap animado se anotan para moverlas mientras se ve (partículas: no se ven en la vista)
        local animados
        local function recoger(copia, objeto, esParte)
            if copia:IsA("ParticleEmitter") then
                copia:Destroy()
                return
            end
            if objeto and MINI.fn[objeto] then
                animados = animados or {}
                local e = animados[objeto]
                if not e then
                    e = { copias = {}, partes = {} }
                    animados[objeto] = e
                end
                if esParte then
                    table.insert(e.partes, copia)
                elseif copia:IsA("Texture") then
                    table.insert(e.copias, copia)
                end
            end
        end
        local modelo = guardada and guardada.modelo or (s and armarModelo(s, w, w and recoger or nil))
        if modelo and #modelo:GetChildren() > 0 then
            if guardada then
                centroVista, tamVista = guardada.centro, guardada.tam
                transparenciasVista, opacidadAplicada = guardada.transp, guardada.op
            else
                local cf, tam = modelo:GetBoundingBox()
                centroVista, tamVista = cf.Position, tam
                modelo.WorldPivot = CFrame.new(centroVista)
                transparenciasVista, opacidadAplicada = nil, 1
                if s and PROPIAS[s.nombre] and not w then
                    cacheVista[clave] = { modelo = modelo, centro = centroVista, tam = tamVista }
                end
            end
            modelo.Parent = visor
            modeloVista = modelo
            MINI.visor = animados
            opacarVista()
            encuadrar()
            girar(abierta() and paginas[paginaActual] == paginaSkins)
        else
            if modelo then modelo:Destroy() end
            if w then
                muestraGrande.Visible = true
                dibujarMuestra(w, muestraGrande, 40)
            end
        end
    end

    -- lo que tienes puesto (cuando el mouse no está sobre ninguna tarjeta)
    local function vistaPorDefecto()
        if not (biblioteca and armaActual) then
            limpiarVisor()
            tituloVista.Text = "Saca un arma"
            detalleVista.Text = "y aquí se ve cómo queda"
            return
        end
        local s = skinMostrada(armaActual, skinRealActual)
        local w = porWrap[eleccionesWrap[armaActual] or ""]
        if INV.por[armaActual] then w = INV.de(w) end
        mostrarEnVisor(s, w, s and s.nombre or armaActual,
            "lo que tienes puesto" .. (w and ("  ·  wrap " .. w.texto) or ""), opacidadDe(armaActual))
    end

    -- la vista gira despacito mientras se ve la página
    girar = function(activo)
        if activo and not giro then
            local inicio = os.clock()
            giro = RunService.RenderStepped:Connect(function()
                if modeloVista and centroVista then
                    local a = math.sin((os.clock() - inicio) * 1.1) * 0.55
                    modeloVista:PivotTo(CFrame.new(centroVista) * CFrame.Angles(0, a, 0))
                end
            end)
        elseif not activo and giro then
            giro:Disconnect()
            giro = nil
        end
    end

    local function ocultarVista()
        girar(false)
        limpiarVisor()
    end

    local function actualizarCabecera()
        local enSkins = modo() == "skins"
        if armaActual then
            etiquetaArma.Text = "En la mano: " .. armaActual
            if enSkins then
                local s = elecciones[armaActual] and porClave[elecciones[armaActual]]
                etiquetaPuesta.Text = s and ("Skin puesta: " .. s.nombre) or "Skin: la tuya (original)"
                etiquetaPuesta.TextColor3 = s and C.acento or C.tenue
            else
                local w = porWrap[eleccionesWrap[armaActual] or ""]
                etiquetaPuesta.Text = w and ("Wrap puesto: " .. w.texto) or "Wrap: ninguno"
                etiquetaPuesta.TextColor3 = w and C.acento or C.tenue
            end
        else
            etiquetaArma.Text = "Saca un arma para elegir"
            etiquetaPuesta.Text = "-"
            etiquetaPuesta.TextColor3 = C.tenue
        end
        botonOriginal.Text = enSkins and "ORIGINAL" or "SIN WRAP"
        botonInvertido.Visible = not enSkins and armaActual ~= nil
        -- (v6.92) con INVERTIDO a la vista, ORIGINAL / SIN WRAP comparte la fila; si no, ocupa toda
        botonOriginal.Size = botonInvertido.Visible and UDim2.new(0.5, -4, 0, 32) or UDim2.new(1, 0, 0, 32)
        contextoTop.Text = armaActual or ""
        contextoTop.Visible = (paginaActual == "skins" or paginaActual == "wraps") and armaActual ~= nil
        local inv = armaActual and INV.por[armaActual]
        botonInvertido.Text = inv and "INVERTIDO: SÍ" or "INVERTIDO: NO"
        botonInvertido.TextColor3 = inv and C.acento or C.tenue
        pildoraOpacidad.Visible = armaActual ~= nil
        if armaActual and not arrastrandoOpacidad then pintarOpacidad(opacidadDe(armaActual)) end
        filtro.Visible = enSkins
        cajaBuscar.Size = enSkins and UDim2.new(1, -270, 0, 36) or UDim2.new(1, 0, 0, 36)
        for boton, activo in pairs({ [botonEstaArma] = not mostrarTodas and not MINI.propias, [botonTodas] = mostrarTodas, [MINI.bProp] = MINI.propias == true }) do
            boton.BackgroundTransparency = activo and 0 or 1
            boton.TextColor3 = activo and C.oscuro or C.tenue
        end
        if acomodarSkins then acomodarSkins() end
        botonTodas.Text = (armaActual and esCuerpoACuerpo(armaActual)) and "CUERPO A CUERPO"
            or (armaActual and esDeFuego(armaActual)) and "ARMAS 1 Y 2" or "TODAS"
        botonSonidos.Text = sonidosActivos and "🔊  Sonidos de la skin: SÍ" or "🔈  Sonidos de la skin: NO"
        botonSonidos.BackgroundColor3 = sonidosActivos and C.panel2 or C.panel
        botonSonidos.TextColor3 = sonidosActivos and C.acento or C.tenue
    end

    -- una tarjeta: la imagen (skin) o la muestra (wrap) arriba y el nombre abajo
    local tarjetaMirada = nil
    local function nuevaTarjeta(texto, detalle, elegida, dibujarMiniatura, alElegir, alMirar)
        local tarjeta = crear("TextButton", {
            LayoutOrder = #tarjetas + 1, Text = "", AutoButtonColor = false,
            BackgroundColor3 = elegida and C.panel2 or C.panel, Parent = lista,
        }, { esquina(16) })
        local borde = trazo(C.acento, elegida and 2 or 1.5, elegida and 0 or 1)
        borde.Parent = tarjeta
        local marco = crear("Frame", {
            Position = UDim2.fromOffset(7, 7), Size = UDim2.new(1, -14, 0, 84),
            BackgroundColor3 = C.oscuro, BorderSizePixel = 0, ClipsDescendants = true, Parent = tarjeta,
        }, { esquina(11) })
        dibujarMiniatura(marco)
        crear("TextLabel", {
            Text = texto, Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = elegida and C.acento or C.texto, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 95), Size = UDim2.new(1, -20, 0, 16), Parent = tarjeta,
        })
        crear("TextLabel", {
            Text = detalle, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.tenue,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 111), Size = UDim2.new(1, -20, 0, 14),
            Parent = tarjeta,
        })
        tarjeta.MouseButton1Click:Connect(alElegir)
        tarjeta.MouseEnter:Connect(function()
            if not elegida then borde.Transparency = 0.35 end
            tarjetaMirada = tarjeta
            pcall(alMirar)
        end)
        tarjeta.MouseLeave:Connect(function()
            if not elegida then borde.Transparency = 1 end
            task.delay(0.15, function()
                if tarjetaMirada == tarjeta then
                    tarjetaMirada = nil
                    vistaPorDefecto()
                end
            end)
        end)
        table.insert(tarjetas, tarjeta)
    end

    local function miniaturaSkin(s)
        return function(marco)
            local imagen = IMAGEN_DE[s.nombre]
            if imagen then
                crear("ImageLabel", {
                    Image = imagen, ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = marco,
                })
            end
        end
    end

    local function miniaturaWrap(w)
        return function(marco)
            dibujarMuestra(w, marco, 22) -- provisional: la de verdad (3D) se arma cuando la tarjeta se ve
            table.insert(MINI.items, { marco = marco, w = w })
        end
    end

    local refrescarLista

    local function refrescarTodo()
        refrescarLista()
        actualizarCabecera()
    end

    refrescarLista = function()
        tarjetaMirada = nil
        for _, tarjeta in ipairs(tarjetas) do tarjeta:Destroy() end
        table.clear(tarjetas)
        MINI.items = {}
        local filtroTexto = cajaBuscar.Text:lower()
        if armaActual and modo() == "skins" then
            local puesta = elecciones[armaActual]
            local wrapPuesto = porWrap[eleccionesWrap[armaActual] or ""]
            local fuente = compatibles(armaActual)
            if mostrarTodas or MINI.propias then
                fuente = catalogo
                if esCuerpoACuerpo(armaActual) then
                    -- (v6.0) en un arma cuerpo a cuerpo solo salen las de otras armas cuerpo a cuerpo
                    fuente = {}
                    for _, s in ipairs(catalogo) do
                        if esCuerpoACuerpo(armaDeLaSkin(s)) then table.insert(fuente, s) end
                    end
                elseif esDeFuego(armaActual) then
                    -- (v6.13) en una primaria o secundaria salen las de todas las primarias y secundarias
                    fuente = {}
                    for _, s in ipairs(catalogo) do
                        if esDeFuego(armaDeLaSkin(s)) then table.insert(fuente, s) end
                    end
                end
                -- (v6.92) PROPIAS: de esas, solo las que hice yo
                if MINI.propias then
                    local propias = {}
                    for _, s in ipairs(fuente) do
                        if PROPIAS[s.nombre] then table.insert(propias, s) end
                    end
                    fuente = propias
                end
            end
            for _, s in ipairs(fuente) do
                if filtroTexto == "" or s.nombre:lower():find(filtroTexto, 1, true) then
                    local deArma = ARMA_DE[s.nombre] or (s.categoria == "Weapons" and s.nombre) or "?"
                    local detalle = deArma .. "  ·  " .. s.categoria
                    nuevaTarjeta(s.nombre, detalle, s.clave == puesta, miniaturaSkin(s), function()
                        if armaActual then
                            elecciones[armaActual] = s.clave
                            guardar()
                            refrescarTodo()
                        end
                    end, function()
                        mostrarEnVisor(s, wrapPuesto, s.nombre, detalle, opacidades[s.clave] or 100)
                    end)
                end
            end
        elseif armaActual then
            local puesto = eleccionesWrap[armaActual]
            local base = skinMostrada(armaActual, skinRealActual)
            for _, w in ipairs(wraps) do
                if filtroTexto == "" or w.texto:lower():find(filtroTexto, 1, true) then
                    nuevaTarjeta(w.texto, "wrap", w.nombre == puesto, miniaturaWrap(w), function()
                        if armaActual then
                            eleccionesWrap[armaActual] = w.nombre
                            guardar()
                            refrescarTodo()
                        end
                    end, function()
                        mostrarEnVisor(base, INV.por[armaActual] and INV.de(w) or w, w.texto,
                            base and ("puesto en " .. base.nombre) or "wrap", opacidadDe(armaActual))
                    end)
                end
            end
        end
        if not armaActual then
            vacio.Text = "Saca un arma (tecla 1, 2...) y aparecen sus skins."
        elseif modo() == "skins" and MINI.propias and filtroTexto == "" then
            vacio.Text = "No hay skins propias para este tipo de arma."
        elseif modo() == "skins" and not mostrarTodas and filtroTexto == "" then
            vacio.Text = "No encontré skins de esta arma. Toca " .. botonTodas.Text .. " para ver las demás."
        else
            vacio.Text = "Nada con ese nombre."
        end
        vacio.Visible = #tarjetas == 0
        vistaPorDefecto()
    end

    MINI.fn = WRAPANIM.fn
    -- (v6.19) LA TELA DEL JUEGO. Cada tarjeta del menú de wraps de Rivals es una pantalla 3D (ViewportFrame) con un modelo "Wrap" de
    -- tres piezas de malla (el rollo de tela) a las que el juego les pone el wrap: las piezas con WrapGroup 1 (la tela y el
    -- rollo) y la de WrapGroup 2 (el borde de abajo). Medidas copiadas de una tarjeta del juego (explorador 28).
    MINI.TELA = {
        { malla = 17589140369, grupo = 2, tam = Vector3.new(0.4169776141643524, 0.15, 0.0975), pos = Vector3.new(0, -0.1087188795208931, -0.1087646558880806) },
        { malla = 17589140491, grupo = 1, tam = Vector3.new(0.057196952402591705, 0.05719694867730141, 0.417187362909317), pos = Vector3.new(0.13330078125, 0, 0) },
        { malla = 17589140223, grupo = 1, tam = Vector3.new(0.4169776141643524, 0.15, 0.3075), pos = Vector3.new(0, 0.0344696044921875, 0.034423828125) },
    }
    MINI.GIRO = CFrame.Angles(-math.rad(45), 0, 0)
    MINI.CAMARA = CFrame.new(-0.3303661048412323, 0.258819043636322, -0.9076733589172363, -0.9396926164627075, 0.0885213315486908,
        -0.3303661048412323, 0, 0.9659258127212524, 0.258819043636322, 0.3420201539993286, 0.2432103455066681, -0.9076733589172363)

    -- las tres mallas se piden una sola vez (tardan en bajar) y después se copian para cada tarjeta
    function MINI.preparar()
        if MINI.moldes ~= nil or MINI.preparando then return end
        MINI.preparando = true
        task.spawn(function()
            local piezas = {}
            local ok = pcall(function()
                local servicio = game:GetService("AssetService")
                for i, d in ipairs(MINI.TELA) do
                    local id = "rbxassetid://" .. d.malla
                    local bien, p = pcall(function() return servicio:CreateMeshPartAsync(id) end)
                    if not (bien and p) then
                        p = Instance.new("MeshPart") -- plan B: algunos ejecutores dejan poner la malla directo
                        p.MeshId = id
                    end
                    p.Size = d.tam
                    p.Anchored = true
                    p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
                    p.CastShadow = true
                    p.Material = Enum.Material.SmoothPlastic
                    p.Color = Color3.fromRGB(163, 162, 165)
                    p.CFrame = CFrame.new(d.pos) * MINI.GIRO
                    p:SetAttribute("WrapGroup", d.grupo)
                    piezas[i] = p
                end
            end)
            MINI.moldes = ok and #piezas == #MINI.TELA and piezas or false
            MINI.preparando = false
            if not MINI.moldes then GARRAS.anotar("miniaturas de wraps: no pude pedir la malla de la tela; uso láminas") end
        end)
    end

    -- una miniatura 3D: lo que se ve en la tarjeta del juego (el rollo de tela con el wrap), o tres láminas si no hay malla
    function MINI.construir(it)
        local marco = it.marco
        if not marco.Parent then return false end
        if MINI.moldes == nil then
            MINI.preparar()
            return false
        end
        local w = INV.por[armaActual] and INV.de(it.w) or it.w
        local lado = math.max(marco.AbsoluteSize.Y, 40)
        local vf = Instance.new("ViewportFrame")
        vf.AnchorPoint = Vector2.new(0.5, 0.5)
        vf.Position = UDim2.fromScale(0.5, 0.5)
        vf.Size = UDim2.fromOffset(lado, lado)
        vf.BackgroundTransparency = 1
        vf.BorderSizePixel = 0
        vf.ZIndex = 6
        vf.Ambient = Color3.fromRGB(200, 200, 200)
        vf.LightColor = Color3.fromRGB(255, 255, 255)
        vf.LightDirection = Vector3.new(0, -1, -0.5)
        local cam = Instance.new("Camera")
        cam.FieldOfView = 25
        cam.Parent = vf
        vf.CurrentCamera = cam
        local modelo = Instance.new("Model")
        modelo.Name = "Wrap"
        if MINI.moldes then
            -- el cielo de la tarjeta (los reflejos del metal y el vidrio)
            local cielo = Instance.new("Sky")
            cielo.SkyboxBk, cielo.SkyboxDn, cielo.SkyboxFt = "rbxassetid://14147881792", "rbxassetid://14147882149", "rbxassetid://14147882761"
            cielo.SkyboxLf, cielo.SkyboxRt, cielo.SkyboxUp = "rbxassetid://14147883091", "rbxassetid://14147882405", "rbxassetid://14147881297"
            cielo.CelestialBodiesShown = false
            cielo.Parent = vf
            for _, molde in ipairs(MINI.moldes) do
                local p = molde:Clone()
                pcall(ponerWrapEn, p, w)
                p.Parent = modelo
            end
            cam.CFrame = MINI.CAMARA
        else
            local ancho, alto = 4.2, 0.95
            for g = 1, 3 do
                local p = Instance.new("Part")
                p.Size = Vector3.new(ancho, alto, 0.2)
                p.Anchored = true
                p.Material = Enum.Material.SmoothPlastic
                p.Color = Color3.fromRGB(205, 205, 210)
                p.CFrame = CFrame.new(0, (2 - g) * alto, 0)
                p:SetAttribute("WrapGroup", g)
                pcall(ponerWrapEn, p, w)
                p.Parent = modelo
            end
            cam.FieldOfView = 30
            cam.CFrame = CFrame.lookAt(Vector3.new(0, 0, -7), Vector3.new(0, 0, 0))
        end
        modelo.Parent = vf
        vf.Parent = marco
        it.vf = vf
        return true
    end

    -- se arman las miniaturas de las filas que se ven (de a una por pasada) y se sueltan las que quedaron lejos
    function MINI.pasada()
        local alto = lista.AbsoluteSize.Y
        local y0 = lista.CanvasPosition.Y
        local fila0 = math.floor((y0 - 3) / 140) - 1
        local fila1 = math.floor((y0 + alto) / 140) + 1
        local armadas = 0
        for i, it in ipairs(MINI.items) do
            local fila = math.floor((i - 1) / (MINI.cols or 4))
            if fila >= fila0 and fila <= fila1 then
                if not it.vf and armadas < 1 then
                    if MINI.construir(it) then armadas = armadas + 1 end
                end
            elseif it.vf and (fila < fila0 - 3 or fila > fila1 + 3) then
                it.vf:Destroy()
                it.vf = nil
            end
        end
    end

    table.insert(conexionesUI, RunService.Heartbeat:Connect(function()
        local ahora = os.clock()
        local visible = abierta() and paginas[paginaActual] == paginaSkins
        -- las miniaturas 3D de los wraps
        if ahora >= MINI.proximo then
            MINI.proximo = ahora + 0.15
            if visible and modo() == "wraps" and #MINI.items > 0 then pcall(MINI.pasada) end
        end
        -- la vista grande: si el wrap tiene animación, se mueve (espaciado según lo que cuesta)
        if MINI.visor and visible and ahora >= MINI.proximoVisor then
            local desde = ahora
            local t = workspace:GetServerTimeNow()
            for objeto, e in pairs(MINI.visor) do
                local f = WRAPANIM.fn[objeto]
                if f then
                    local dt = e.ult and ahora - e.ult or 0
                    e.ult = ahora
                    pcall(f, e, t, dt)
                end
            end
            MINI.proximoVisor = ahora + math.clamp((os.clock() - desde) * 16, 1 / 30, 0.3)
        end
    end))

    botonInvertido.MouseButton1Click:Connect(function()
        if not armaActual then return end
        INV.por[armaActual] = not INV.por[armaActual] or nil
        guardar()
        refrescarTodo() -- las miniaturas y la vista; la próxima revisión le cambia el arma en la mano
    end)

    botonOriginal.MouseButton1Click:Connect(function()
        if armaActual then
            if modo() == "skins" then
                elecciones[armaActual] = nil
            else
                eleccionesWrap[armaActual] = nil
            end
            guardar()
            refrescarTodo()
        end
    end)

    local function cambiarFiltro(todas)
        if mostrarTodas == todas and not MINI.propias then return end
        mostrarTodas = todas
        MINI.propias = false
        lista.CanvasPosition = Vector2.zero
        refrescarTodo()
    end
    MINI.bProp.MouseButton1Click:Connect(function()
        if MINI.propias then return end
        MINI.propias = true
        mostrarTodas = false
        lista.CanvasPosition = Vector2.zero
        refrescarTodo()
    end)
    botonEstaArma.MouseButton1Click:Connect(function() cambiarFiltro(false) end)
    botonTodas.MouseButton1Click:Connect(function() cambiarFiltro(true) end)

    -- (v6.92, rediseno C) cada cosa de la pagina en su lugar segun el ancho: arriba la vista (a la izquierda) y a su derecha el titulo y los controles; debajo el buscador con
    -- el filtro y las tarjetas en 3 a 6 columnas segun lo que quepa
    acomodarSkins = function()
        local ancho = contenido.AbsoluteSize.X
        if ancho <= 0 or contenido.AbsoluteSize.Y <= 0 then return end
        local enSkins = modo() == "skins"
        local anchoVista = math.clamp(math.floor(ancho * 0.36), 190, 260)
        local x1 = anchoVista + 14
        panelVista.Size = UDim2.fromOffset(anchoVista, 178)
        etiquetaArma.Position = UDim2.fromOffset(x1, 0)
        etiquetaArma.Size = UDim2.new(1, -x1 - 168, 0, 28)
        filaPuesta.Position = UDim2.fromOffset(x1, 32)
        filaPuesta.Size = UDim2.new(1, -x1, 0, 146)
        local anchoFiltro = enSkins and 262 or 0
        cajaBuscar.Size = UDim2.new(1, enSkins and -(anchoFiltro + 8) or 0, 0, 36)
        local util = ancho - 11 -- menos el relleno de la lista (3 + 8)
        local columnas = math.clamp(math.floor((util + 8) / 128), 3, 6)
        MINI.cols = columnas
        local cuadricula = lista:FindFirstChildOfClass("UIGridLayout")
        if cuadricula then
            cuadricula.CellSize = UDim2.fromOffset(math.floor((util - 8 * (columnas - 1)) / columnas), 132)
        end
    end
    table.insert(conexionesUI, contenido:GetPropertyChangedSignal("AbsoluteSize"):Connect(acomodarSkins))
    task.defer(acomodarSkins)

    botonSonidos.MouseButton1Click:Connect(function()
        sonidosActivos = not sonidosActivos
        firmaSonidos = nil -- que se vuelva a preparar
        guardar()
        actualizarCabecera()
    end)

    -- la barrita de opacidad: cambia al tiro el arma en la mano (si todavía no estaba vestida,
    -- la viste la próxima revisión) y la vista; se guarda al soltar
    local function ponerOpacidad(valor)
        if not armaActual then return end
        opacidades[claveOpacidad(armaActual)] = valor < 100 and valor or nil
        pintarOpacidad(valor)
        for vm, r in pairs(registro) do
            if armaDe(vm) == armaActual then cambiarOpacidad(r, valor / 100) end
        end
        if not tarjetaMirada then vistaPorDefecto() end
    end

    local function leerOpacidad()
        local ancho = pistaOpacidad.AbsoluteSize.X
        if ancho <= 0 then return end
        local x = UserInputService:GetMouseLocation().X
        ponerOpacidad(math.floor(math.clamp((x - pistaOpacidad.AbsolutePosition.X) / ancho, 0, 1) * 100 + 0.5))
    end

    zonaOpacidad.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and armaActual then
            arrastrandoOpacidad = true
            leerOpacidad()
        end
    end)
    table.insert(conexionesUI, UserInputService.InputChanged:Connect(function(input)
        if arrastrandoOpacidad and input.UserInputType == Enum.UserInputType.MouseMovement then leerOpacidad() end
    end))
    table.insert(conexionesUI, UserInputService.InputEnded:Connect(function(input)
        if arrastrandoOpacidad and input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastrandoOpacidad = false
            guardar()
        end
    end))

    -- al escribir en el buscador se espera un poquito antes de rehacer la lista
    local busqueda = 0
    table.insert(conexionesUI, cajaBuscar:GetPropertyChangedSignal("Text"):Connect(function()
        busqueda = busqueda + 1
        local esta = busqueda
        task.delay(0.15, function()
            if vivo and esta == busqueda then refrescarLista() end
        end)
    end))

    -- al cambiar de página (SKINS <-> WRAPS), achicar o esconder la ventana
    table.insert(alCambiarVentana, function()
        local enSkins = abierta() and paginas[paginaActual] == paginaSkins
        girar(enSkins and biblioteca ~= nil)
        if enSkins and biblioteca and modo() ~= modoMostrado then
            -- de SKINS a WRAPS (o al revés): tarjetas nuevas, sin lo que se buscaba antes
            modoMostrado = modo()
            if cajaBuscar.Text ~= "" then cajaBuscar.Text = "" end
            lista.CanvasPosition = Vector2.zero
            refrescarTodo()
        end
    end)

    -- Revisa el arma en la mano varias veces por segundo ----------------------------

    -- Skins "Key": al apuntar (clic derecho) y al dejar de apuntar suena el llavero
    local function sonidoApuntar(apuntando)
        if not (sonidosActivos and armaActual) or abierta() or UserInputService:GetFocusedTextBox() then return end
        local clave = elecciones[armaActual]
        local s = clave and porClave[clave]
        local id = s and APUNTAR[s.nombre]
        if not id or (skinRealActual and norm(skinRealActual) == norm(s.nombre)) then return end
        tocar({ id }, { Volume = 0.375, PlaybackSpeed = apuntando and 2.1 or 2 })
    end
    table.insert(conexionesUI, UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then pcall(sonidoApuntar, true) end
    end))
    table.insert(conexionesUI, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then pcall(sonidoApuntar, false) end
    end))

    local vistos = setmetatable({}, { __mode = "k" }) -- armas que ya vimos aparecer
    local primeraVuelta = true
    local proximoIntento = 0
    local carpetaVigilada = nil -- workspace.ViewModels.FirstPerson, para vestir al tiro el arma nueva

    local function mostrarPagina()
        avisoRivals.Visible = biblioteca == nil
        contenido.Visible = biblioteca ~= nil
    end

    local function revisar()
        if not biblioteca then
            if os.clock() < proximoIntento then return end
            proximoIntento = os.clock() + 2
            if not prepararBiblioteca() then return end
            mostrarPagina()
            modoMostrado = modo()
            refrescarTodo()
        end

        local vms = workspace:FindFirstChild("ViewModels")
        local primera = vms and vms:FindFirstChild("FirstPerson")
        -- al sacar un arma se viste al tiro, sin esperar la próxima vuelta: así hasta la
        -- animación de sacarla sale con la skin
        if primera and primera ~= carpetaVigilada then
            carpetaVigilada = primera
            table.insert(conexionesUI, primera.ChildAdded:Connect(function()
                task.delay(0.03, function()
                    if vivo then pcall(revisar) end
                end)
            end))
            vigilarSonidos(primera)
        end
        local arma, skinReal = nil, nil
        local sacoArma = false
        if primera then
            for _, vm in ipairs(primera:GetChildren()) do
                local nombreArma, real = armaDe(vm)
                if nombreArma then
                    arma, skinReal = nombreArma, real
                    realesVistas[nombreArma] = real or nombreArma
                    local clave = elecciones[nombreArma]
                    if clave and not porClave[clave] then clave = nil end
                    local nombreWrap = eleccionesWrap[nombreArma]
                    if nombreWrap and not porWrap[nombreWrap] then nombreWrap = nil end
                    local opacidad = opacidadDe(nombreArma) / 100

                    -- se viste si hay skin, wrap u opacidad bajo 100% (la original, de sí misma);
                    -- si solo cambió la opacidad, se le cambia a lo que ya está puesto
                    local r = registro[vm]
                    local vestida = clave or nombreWrap or opacidad < 1
                    local invertido = INV.por[nombreArma] and nombreWrap
                    local deseado = vestida and ((clave or "") .. "|" .. (nombreWrap or "") .. "|" .. (invertido and "1" or "")) or nil
                    local actual = r and ((r.clave or "") .. "|" .. (r.wrap or "") .. "|" .. (r.inv and "1" or "")) or nil
                    if deseado ~= actual then
                        local desdeVestir = os.clock()
                        if deseado then
                            vestir(vm, skinMostrada(nombreArma, real),
                                nombreWrap and (invertido and INV.de(porWrap[nombreWrap]) or porWrap[nombreWrap]), clave,
                                porNombre[real or ""] or porNombre[nombreArma], opacidad)
                        else
                            quitarSkin(vm)
                        end
                        GARRAS.tarde("vestir/quitar " .. tostring(nombreArma), desdeVestir)
                    elseif r and r.opacidad ~= opacidad then
                        cambiarOpacidad(r, opacidad)
                    end

                    if not vistos[vm] then
                        vistos[vm] = true
                        sacoArma = true
                        local desdeEfecto = os.clock()
                        if not primeraVuelta then pcall(efectoSacar, vm, nombreArma, real) end
                        GARRAS.tarde("efectoSacar", desdeEfecto)
                    end
                end
            end
        end

        -- por si se escapó algún cambio: cada copia sigue a su pieza de verdad
        local desdeVis = os.clock()
        for _, r in pairs(registro) do
            for _, g in ipairs(r.grupos) do aplicarVisibilidad(g) end
        end
        GARRAS.tarde("aplicarVisibilidad", desdeVis)

        local desdeBarra = os.clock()
        revisarBarra()
        GARRAS.tarde("revisarBarra", desdeBarra)

        local skinElegida = arma and elecciones[arma] and porClave[elecciones[arma]]
        local firmaNueva = (arma or "") .. "|" .. (skinReal or "") .. "|" .. (skinElegida and skinElegida.nombre or "")
            .. "|" .. tostring(sonidosActivos)
        if firmaNueva ~= firmaSonidos then
            firmaSonidos = firmaNueva
            local desdeSon = os.clock()
            prepararSonidos(arma, skinReal, skinElegida and skinElegida.nombre)
            GARRAS.tarde("prepararSonidos", desdeSon)
        end

        -- sonido de sacar el arma (si la skin tiene y el arma normal no)
        if sacoArma and sonidoSacar and not primeraVuelta then tocar(sonidoSacar) end
        primeraVuelta = false

        if arma ~= armaActual then
            armaActual, skinRealActual = arma, skinReal
            lista.CanvasPosition = Vector2.zero
            local desdeRef = os.clock()
            refrescarTodo()
            GARRAS.tarde("refrescarTodo (cambio de arma a " .. tostring(arma) .. ")", desdeRef)
        end
    end

    -- todas las armas como estaban: se borran las skins, wraps y opacidades elegidas, y la próxima
    -- revisión (se hace al tiro) les saca las copias y devuelve los íconos de la barra
    local function restablecer()
        table.clear(elecciones)
        table.clear(eleccionesWrap)
        table.clear(opacidades)
        guardar()
        if biblioteca then
            refrescarTodo()
            pcall(revisar)
        end
    end
    conConfirmacion(botonTodoOriginal, function()
        restablecer()
        aviso("Armas como estaban: sin skins, sin wraps y con opacidad 100 %.")
    end, "¿Seguro? Otra vez")

    local function iniciar()
        prepararBiblioteca()
        mostrarPagina()
        modoMostrado = modo()
        refrescarTodo()
    end

    local function limpiar()
        ocultarVista()
        local vmsPuestas = {}
        for vm in pairs(registro) do table.insert(vmsPuestas, vm) end
        for _, vm in ipairs(vmsPuestas) do pcall(quitarSkin, vm) end
        local puestos = {}
        for icono in pairs(iconos) do table.insert(puestos, icono) end
        for _, icono in ipairs(puestos) do pcall(devolverIcono, icono) end
    end

    return {
        iniciar = iniciar, revisar = revisar, limpiar = limpiar, restablecer = restablecer,
        enRivals = function() return biblioteca ~= nil end,
        -- lo que necesita PROYECTILES: la skin elegida de cada arma, la de verdad y el arma en la mano
        consultaProyectiles = function()
            local elegidas = {}
            for nombreArma, clave in pairs(elecciones) do
                local s = porClave[clave]
                if s then elegidas[nombreArma] = s.nombre end
            end
            return { enMano = armaActual, real = skinRealActual, elegidas = elegidas, reales = realesVistas,
                sonidos = sonidosActivos }
        end,
        -- el wrap que elegiste para un arma, puesto en un modelo (el proyectil de la skin)
        envolver = function(modelo, nombreArma)
            local w = porWrap[eleccionesWrap[nombreArma] or ""]
            if not w then return end
            if INV.por[nombreArma] then w = INV.de(w) end
            for _, d in ipairs(modelo:GetDescendants()) do
                if d:IsA("BasePart") then pcall(ponerWrapEn, d, w) end
            end
        end,
        cuantas = function() return #catalogo, #wraps end,
        -- (v6.87) la definicion de una skin propia (PROPIAS[nombre]): lo que tiene que ver con efectos (def.efecto, def.rotura) lo usan PROYECTILES
        propia = function(nombre) return PROPIAS[nombre] end,
        -- (v6.25) el modelo que el juego clona para lo que se tira de esa arma (la lanza clavada: Assets.SpearTightropes) hecho con las piezas
        -- de una skin propia: el cuerpo con la punta pegada al Primary y el resto hacia -Y. Va a escala 1: vestirProyectil le hace ScaleTo(2) como al del juego
        plantillaPropia = function(nombre, nombreCarpeta)
            local def, s = PROPIAS[nombre], porNombre[nombre]
            local p = def and def.proyectil
            if not (p and s and p.carpeta == nombreCarpeta) then return nil end
            if p.hecha then return p.hecha end
            local cuerpo = s.modelo:FindFirstChild("Body")
            local base = cuerpo and principalDe(cuerpo)
            if not base then return nil end
            local m = Instance.new("Model")
            m.Name = nombre
            local prim = Instance.new("Part")
            prim.Name, prim.Size, prim.Transparency, prim.Anchored, prim.CanCollide = "Primary", Vector3.new(0.5, 0.5, 0.5), 1, true, false
            prim.CFrame = CFrame.new()
            prim.Parent = m
            m.PrimaryPart = prim
            -- (v6.87) p.marco (12 numeros: un CFrame): donde esta la figura dentro del marco del arma (la pocion va inclinada en la mano); lo que se tira se arma con la
            -- figura DERECHA, centrada en el Primary (el juego la hace girar alrededor de ahi)
            local marco = p.marco and CFrame.new(table.unpack(p.marco)) or nil
            for _, d in ipairs(cuerpo:GetChildren()) do
                if d:IsA("BasePart") and d ~= base then
                    local rel = base.CFrame:ToObjectSpace(d.CFrame)
                    local c = d:Clone()
                    c.Size = d.Size * p.escala
                    if marco then
                        local loc = marco:ToObjectSpace(rel)
                        c.CFrame = CFrame.new(loc.Position * p.escala) * (loc - loc.Position)
                    else
                        c.CFrame = CFrame.new((rel.Position - Vector3.new(0, p.punta, 0)) * p.escala + Vector3.new(0, p.y0, 0)) * (rel - rel.Position)
                    end
                    c.Anchored = true
                    c.Parent = m
                end
            end
            m.WorldPivot = prim.CFrame
            p.hecha = m
            return m
        end,
    }
end)()

-- ============================================================================
-- PROYECTILES (v5.0): lo que tiras o disparas con una skin elegida se ve como el de la skin
-- ============================================================================
-- Rivals dibuja lo que vuela clonando un modelo por nombre (el de tu skin de verdad o, si no
-- tiene, el del arma) de PlayerScripts.Assets.Throwables (granadas, molotovs...) o de
-- Assets.Projectiles (cohetes, flechas, dagas...), directo en workspace, y lo mueve en cada cuadro
-- con PivotTo (y ScaleTo). Lo sacado de su código (Throwable.ReplicateFromServer y
-- Gun._ProjectileEffect, explorador 19). Acá se mete adentro de ese clon el modelo de la skin
-- elegida y se esconde lo original: el juego lo sigue moviendo, agrandando y escondiendo al final
-- como si fuera el suyo. Además:
--   - rayos (Energy Rifle...): se tiñen con la plantilla del rayo de la skin (Assets.Misc)
--   - balas normales (TracerEffect): con el color de trazadora de la skin
--   - explosión normal (una Part invisible con Misc.ExplosionEffect.Attachment): se cambia por la
--     plantilla de la skin, escalada igual, con sus sonidos
-- Solo lo tuyo: lo que nace a pocos studs de tu cámara. Lo de los demás no se toca.

local moduloProyectiles = (function()
    local RAYOS, TRAZ, EXPLOS = {}, {}, {}
    pcall(function()
        local datos = loadstring(leer(ruta("skins_efectos.lua")))()
        RAYOS = datos.rayos or {}
        TRAZ = datos.trazadoras or {}
        EXPLOS = datos.explosiones or {}
    end)
    local CERCA = 16          -- studs desde la cámara a los que nace lo tuyo
    local LEJOS = 45          -- ...o hasta acá si acabas de disparar o tirar (llega con tu ping)
    local conexiones = {}
    local propios = {}        -- proyectiles tuyos vestidos: { modelo, skin, hasta }
    local pendientes = {}     -- rayos y balas nuevos, se miran al cuadro siguiente: { parte, tipo, dato, t }
    local ultimoDisparo = -10 -- el último clic
    local ultimaAccion = -10  -- el último clic o tecla de tirar
    -- (v6.87) POCION DE DAÑO: POC = el ultimo proyectil tuyo vestido (donde iba y cuando) y cuando lo tiraste; estelaPocion se arma mas abajo (la usa vestirProyectil)
    local POC = { pos = nil, t = -100, lanzada = -100 }
    local estelaPocion, sonarVidrio, sonarLanzar
    local TECLAS_TIRAR = { [Enum.KeyCode.G] = true, [Enum.KeyCode.F] = true, [Enum.KeyCode.Q] = true, [Enum.KeyCode.E] = true }

    local function disparando()
        return os.clock() - ultimoDisparo < 0.6 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end

    local function carpeta(nombre)
        local ok, a = pcall(function() return jugador.PlayerScripts.Assets end)
        return ok and a and a:FindFirstChild(nombre) or nil
    end

    -- Qué buscar, según lo elegido en SKINS (se rearma a lo más cada medio segundo):
    --   modelos: nombre del modelo que clona el juego -> { skin, arma, plantilla }
    --   rayos: plantilla de rayo del arma en la mano -> la de la skin
    --   bala: color de trazadora de la skin del arma en la mano (o nil)
    local mapas, hechoEn = { modelos = {}, rayos = {}, sonidos = true }, -10
    local function buscar()
        if os.clock() - hechoEn < 0.5 then return mapas end
        hechoEn = os.clock()
        local ok, c = pcall(moduloSkins.consultaProyectiles)
        if not ok or not c then return mapas end
        local nuevos = { modelos = {}, rayos = {}, impactos = {}, bala = nil, llamas = nil, sonidos = c.sonidos,
            elegidas = c.elegidas }
        -- (v5.4) todas las carpetas de Assets con un modelo por arma o skin (no solo Throwables y
        -- Projectiles: el Jump Pad y la Tripmine pueden venir de otra)
        local nombresCarpetas = { "Throwables", "Projectiles" }
        local raizAssets = carpeta("Throwables") and carpeta("Throwables").Parent
        for _, f in ipairs(raizAssets and raizAssets:GetChildren() or {}) do
            if f:IsA("Folder") and not table.find(nombresCarpetas, f.Name)
                and f.Name ~= "ViewModels" and f.Name ~= "WrapTextures" and f.Name ~= "Misc" then
                table.insert(nombresCarpetas, f.Name)
            end
        end
        for _, nombreCarpeta in ipairs(nombresCarpetas) do
            local f = carpeta(nombreCarpeta)
            if f then
                for nombreArma, skin in pairs(c.elegidas) do
                    local plantilla = f:FindFirstChild(skin) or moduloSkins.plantillaPropia(skin, nombreCarpeta)
                    if plantilla then
                        for _, base in ipairs({ c.reales[nombreArma], nombreArma }) do
                            if base and base ~= skin and f:FindFirstChild(base) and not nuevos.modelos[base] then
                                nuevos.modelos[base] = {
                                    skin = skin, arma = nombreArma, plantilla = plantilla,
                                    lanzable = nombreCarpeta == "Throwables",
                                }
                            end
                        end
                    end
                end
            end
        end
        local arma = c.enMano
        local skin = arma and c.elegidas[arma]
        if skin then
            local real = c.real or arma
            local deJuego, deSkin = RAYOS[real] or RAYOS[arma], RAYOS[skin]
            if deJuego and deSkin and deJuego ~= deSkin then nuevos.rayos[deJuego] = deSkin end
            local rgb = TRAZ[skin]
            if rgb and TRAZ[real] ~= rgb then nuevos.bala = Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end
            -- impactos con su propia plantilla (la Exogun: donde pega sale "ExogunExplosionParticles")
            local eJuego, eSkin = EXPLOS[real] or EXPLOS[arma], EXPLOS[skin]
            if eJuego and eSkin and eJuego.p ~= eSkin.p then nuevos.impactos[eJuego.p] = skin end
            -- el fuego del lanzallamas: Misc.FlamethrowerFlames trae uno por skin
            local llamas = carpeta("Misc")
            llamas = llamas and llamas:FindFirstChild("FlamethrowerFlames")
            if llamas and llamas:FindFirstChild(skin) and skin ~= real then
                nuevos.llamas = { skin = llamas[skin], juego = llamas:FindFirstChild(real) or llamas:FindFirstChild(arma) }
            end
        end
        mapas = nuevos
        return mapas
    end

    -- esconde lo del juego (las partes con LocalTransparencyModifier, como hace él al final; lo que
    -- brilla o echa partículas, apagado) y devuelve cómo estaba, por si no era tuyo
    local function esconder(modelo, excepto)
        local hechos = {}
        for _, d in ipairs(modelo:GetDescendants()) do
            if not (excepto and d:IsDescendantOf(excepto)) then
                if d:IsA("BasePart") then
                    hechos[d] = d.LocalTransparencyModifier
                    d.LocalTransparencyModifier = 1
                elseif d:IsA("Decal") then -- (v6.27) Decal y Texture (el wrap de la skin de verdad) no siguen al LocalTransparencyModifier: se vería su silueta
                    hechos[d] = d.Transparency
                    d.Transparency = 1
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Light")
                    or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
                    hechos[d] = d.Enabled
                    d.Enabled = false
                    if d:IsA("ParticleEmitter") then d:Clear() end
                end
            end
        end
        return hechos
    end

    local function devolver(hechos)
        for d, v in pairs(hechos) do
            pcall(function()
                if d:IsA("BasePart") then d.LocalTransparencyModifier = v elseif d:IsA("Decal") then d.Transparency = v else d.Enabled = v end
            end)
        end
    end

    -- ¿es tuyo? El juego lo lleva a su lugar en los primeros cuadros: lo tuyo nace cerca de tu cámara
    -- (o un poco más allá si es rápido, una flecha o un cohete, porque llega con tu ping)
    -- (v5.2) el juego no lo pone de golpe: lo desliza desde donde guarda la plantilla (~2000 studs),
    -- así que se mira medio segundo y vale si en algún cuadro pasó cerca de ti
    local function esPropio(modelo)
        local reciente = os.clock() - ultimaAccion < 1.2
        local limite = os.clock() + 0.5
        while os.clock() < limite do
            RunService.RenderStepped:Wait()
            if not modelo.Parent then return false end
            local camara = workspace.CurrentCamera
            local d = camara and (modelo:GetPivot().Position - camara.CFrame.Position).Magnitude or math.huge
            if d < CERCA or (reciente and d < LEJOS) then return true end
        end
        return false
    end

    local function vestirProyectil(modelo, datos)
        local copia = datos.plantilla:Clone()
        copia.Name = "CieloProyectil"
        -- como el juego: a lo que se tira le pone el pivote en su Primary; a los proyectiles, no
        local primaria = copia:FindFirstChild("Primary")
        if datos.lanzable and primaria and primaria:IsA("BasePart") then copia.WorldPivot = primaria.CFrame end
        for _, d in ipairs(copia:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide, d.CanTouch, d.CanQuery = false, false, false
                d.Massless = true
            end
        end
        pcall(moduloSkins.envolver, copia, datos.arma)
        -- (v5.3) a la misma escala que lleva el del juego: si no, su próximo ScaleTo la agranda de más
        pcall(function() copia:ScaleTo(modelo:GetScale()) end)
        copia:PivotTo(modelo:GetPivot())
        copia.Parent = modelo -- adentro: el PivotTo y el ScaleTo del juego también la mueven a ella
        esconder(modelo, copia)
        table.insert(propios, { modelo = modelo, skin = datos.skin, hasta = os.clock() + 60 })
        -- (v6.87) por donde va lo tuyo: la explosion y el fuego que salen despues (cuando el modelo ya no esta) se reconocen como tuyos por estar cerca de ahi
        POC.lanzada = os.clock()
        task.spawn(function()
            local limite = os.clock() + 20
            while modelo.Parent and os.clock() < limite do
                local ok, p = pcall(function() return modelo:GetPivot().Position end)
                if ok then POC.pos, POC.t = p, os.clock() end
                RunService.Heartbeat:Wait()
            end
        end)
        if estelaPocion then pcall(estelaPocion, copia, datos.skin) end
        if sonarLanzar then pcall(sonarLanzar, datos.skin) end
    end

    -- Explosiones -----------------------------------------------------------------------------
    -- la plantilla de una explosión: el Attachment con sus partículas (adentro de su Part en Misc)
    local function plantillaExplosion(nombre)
        local misc = carpeta("Misc")
        local x = misc and misc:FindFirstChild(nombre)
        if x and not x:IsA("Attachment") then x = x:FindFirstChildWhichIsA("Attachment") end
        return x
    end

    -- ¿es la explosión normal? sus partículas se llaman como las de Misc.ExplosionEffect
    local function esExplosionNormal(adjunto)
        local normal = plantillaExplosion("ExplosionEffect")
        if not normal then return false end
        local iguales, total = 0, 0
        for _, e in ipairs(normal:GetChildren()) do
            if e:IsA("ParticleEmitter") then
                total = total + 1
                if adjunto:FindFirstChild(e.Name) then iguales = iguales + 1 end
            end
        end
        return total > 0 and iguales == total
    end

    local function escalarParticulas(e, f)
        local puntos = {}
        for _, k in ipairs(e.Size.Keypoints) do
            table.insert(puntos, NumberSequenceKeypoint.new(k.Time, k.Value * f, k.Envelope * f))
        end
        e.Size = NumberSequence.new(puntos)
        e.Speed = NumberRange.new(e.Speed.Min * f, e.Speed.Max * f)
    end

    -- como PlayParticles del juego: cada emisor larga EmitCount (después de EmitDelay), o queda
    -- prendido EmitDuration segundos; la luz se apaga de a poco
    local function emitir(adjunto)
        for _, e in ipairs(adjunto:GetDescendants()) do
            if e:IsA("ParticleEmitter") then
                local cuantos = e:GetAttribute("EmitCount") or 0
                local espera = e:GetAttribute("EmitDelay") or 0
                local dura = e:GetAttribute("EmitDuration") or 0
                task.delay(espera, function()
                    if not e.Parent then return end
                    if dura > 0 then
                        e.Enabled = true
                        task.delay(dura, function() if e.Parent then e.Enabled = false end end)
                    elseif cuantos > 0 then
                        e:Emit(cuantos)
                    end
                end)
            elseif e:IsA("Light") then
                local brillo = e.Brightness
                task.spawn(function()
                    for i = 1, 20 do
                        task.wait(0.03)
                        if not e.Parent then return end
                        e.Brightness = brillo * (1 - i / 20)
                    end
                end)
            end
        end
    end

    local function callar(s)
        if s:FindFirstChild("CieloSilencio") then return end
        crear("EqualizerSoundEffect", { Name = "CieloSilencio", LowGain = -80, MidGain = -80, HighGain = -80, Parent = s })
    end

    local function sonar(ev, padre)
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. tostring(ev[1])
        s.Volume = ev[2] or 1
        s.PlaybackSpeed = (ev[3] or 1) + (ev[4] or 0) * math.random()
        s:SetAttribute("CieloSonido", true)
        s.Parent = padre
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    end

    local function cambiarExplosion(parte, adjunto, skin, sonidos, nombreNormal)
        local datos = EXPLOS[skin]
        local plantilla = datos and plantillaExplosion(datos.p)
        if not plantilla then return end
        -- cuánto la agrandó el juego (ScaleParticleEmitter con el radio): una partícula suya contra
        -- la misma de la plantilla
        local normal = plantillaExplosion(nombreNormal or "ExplosionEffect")
        local factor = 1
        for _, e in ipairs(adjunto:GetChildren()) do
            local orig = normal and normal:FindFirstChild(e.Name)
            if e:IsA("ParticleEmitter") and orig and orig:IsA("ParticleEmitter") then
                local a, b = e.Size.Keypoints[1].Value, orig.Size.Keypoints[1].Value
                if a > 0 and b > 0 then
                    factor = a / b
                    break
                end
            end
        end
        local luzJuego = adjunto:FindFirstChildWhichIsA("Light", true)
        local nuevo = plantilla:Clone()
        for _, e in ipairs(nuevo:GetDescendants()) do
            if e:IsA("ParticleEmitter") then
                e.Enabled = false
                if math.abs(factor - 1) > 0.01 then escalarParticulas(e, factor) end
            elseif e:IsA("Light") and luzJuego and luzJuego:IsA("PointLight") and e:IsA("PointLight") then
                e.Range = luzJuego.Range
            end
        end
        adjunto:Destroy()
        nuevo.Parent = parte
        emitir(nuevo)
        if sonidos and #datos.s > 0 then
            for _, s in ipairs(parte:GetChildren()) do
                if s:IsA("Sound") then callar(s) end
            end
            -- (la conexión se va sola cuando el juego borra la Part, a los 5 s)
            parte.ChildAdded:Connect(function(s)
                if s:IsA("Sound") and not s:GetAttribute("CieloSonido") then callar(s) end
            end)
            for _, ev in ipairs(datos.s) do sonar(ev, parte) end
        end
    end

    -- una Part invisible y anclada con la explosión normal: si nació donde terminó un proyectil
    -- tuyo, es la tuya
    local function revisarExplosion(parte)
        if parte.Transparency < 0.99 or not parte.Anchored then return end
        local adjunto = parte:FindFirstChildWhichIsA("Attachment")
        if not (adjunto and esExplosionNormal(adjunto)) then return end
        local ahora = os.clock()
        for i = #propios, 1, -1 do
            local x = propios[i]
            if ahora > x.hasta or not x.modelo.Parent then
                table.remove(propios, i)
            elseif EXPLOS[x.skin] and (x.modelo:GetPivot().Position - parte.Position).Magnitude < 14 then
                cambiarExplosion(parte, adjunto, x.skin, buscar().sonidos)
                table.remove(propios, i)
                return
            end
        end
    end

    -- Rayos y balas --------------------------------------------------------------------------
    local function tenirConPlantilla(parte, plantilla)
        for _, d in ipairs(parte:GetDescendants()) do
            local modelo = plantilla:FindFirstChild(d.Name, true)
            if modelo and modelo.ClassName == d.ClassName then
                if d:IsA("Beam") then
                    d.Color, d.Texture, d.TextureLength, d.TextureMode = modelo.Color, modelo.Texture, modelo.TextureLength, modelo.TextureMode
                    d.TextureSpeed, d.LightEmission, d.LightInfluence = modelo.TextureSpeed, modelo.LightEmission, modelo.LightInfluence
                    d.Brightness = modelo.Brightness
                elseif d:IsA("Light") then
                    d.Color = modelo.Color
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") then
                    d.Color = modelo.Color
                end
            end
        end
    end

    local function tenirColor(x, color)
        if x:IsA("Beam") or x:IsA("Trail") or x:IsA("ParticleEmitter") then
            x.Color = ColorSequence.new(color)
        elseif x:IsA("Light") then
            x.Color = color
        end
    end

    -- lo más cerca de tu cámara que tiene una parte nueva (ella o sus Attachment, que en los rayos
    -- van en coordenadas del mundo)
    local function distancia(parte)
        local camara = workspace.CurrentCamera
        if not camara then return math.huge end
        local c = camara.CFrame.Position
        local d = (parte.Position - c).Magnitude
        for _, a in ipairs(parte:GetDescendants()) do
            if a:IsA("Attachment") then d = math.min(d, (a.WorldPosition - c).Magnitude) end
        end
        return d
    end

    -- se miran al cuadro siguiente (ya en su lugar): los que nacen juntos van juntos (un disparo del
    -- Energy Rifle son varios tramos y solo el primero sale cerca de ti)
    local function revisarPendientes()
        if #pendientes == 0 then return end
        local listos, quedan = {}, {}
        for _, x in ipairs(pendientes) do
            if os.clock() - x.t >= 0.01 then table.insert(listos, x) else table.insert(quedan, x) end
        end
        pendientes = quedan
        local mio = false
        for _, x in ipairs(listos) do
            if x.parte.Parent and distancia(x.parte) < CERCA then mio = true break end
        end
        if not mio then return end
        for _, x in ipairs(listos) do
            if x.parte.Parent then
                if x.tipo == "rayo" then
                    local misc = carpeta("Misc")
                    local plantilla = misc and misc:FindFirstChild(x.dato)
                    if plantilla then pcall(tenirConPlantilla, x.parte, plantilla) end
                else
                    for _, d in ipairs(x.parte:GetDescendants()) do pcall(tenirColor, d, x.dato) end
                    -- lo que le ponga el juego después (la estela...) también
                    local con
                    con = x.parte.DescendantAdded:Connect(function(d) pcall(tenirColor, d, x.dato) end)
                    task.delay(1, function() con:Disconnect() end)
                end
            end
        end
    end

    -- Registro (v5.1): qué aparece después de cada disparo o tiro tuyo y qué decide este módulo, en
    -- CieloRoblox/proyectiles_log.txt (se escribe cada 5 s si hay algo nuevo; máx. 4000 líneas)
    local registro, registroNuevo, t0 = {}, false, os.clock()
    local function anotar(texto)
        if #registro >= 4000 then return end
        table.insert(registro, string.format("%.2f %s", os.clock() - t0, texto))
        registroNuevo = true
    end
    local function describir(x)
        local partes = {}
        local n = 0
        for _, d in ipairs(x:GetDescendants()) do
            n = n + 1
            if n > 12 then
                table.insert(partes, "...")
                break
            end
            table.insert(partes, d.ClassName .. ":" .. d.Name)
        end
        return x.ClassName .. " '" .. x:GetFullName() .. "' {" .. table.concat(partes, ", ") .. "}"
    end
    local function distanciaA(x)
        local camara = workspace.CurrentCamera
        if not camara then return -1 end
        local ok, p = pcall(function()
            if x:IsA("Model") then return x:GetPivot().Position end
            if x:IsA("BasePart") then return x.Position end
            if x:IsA("Attachment") then return x.WorldPosition end
            return nil
        end)
        return (ok and p) and math.floor((p - camara.CFrame.Position).Magnitude * 10) / 10 or -1
    end

    -- ===== (v6.87) POCION DE DAÑO (skin propia "Pocion de dano" del Molotov, def.efecto = "pocion") =====
    -- Las particulas de la pocion persistente de Minecraft (espirales y aros, ROJOS: pocion de daño instantaneo) en vez del fuego: texturas propias (pocion_remolino_1/2.png y
    -- pocion_aro.png, las deja la app en la carpeta de Cielo, se cargan con getcustomasset). Se cambian: (1) la zona de fuego del suelo (Misc.FireHitboxes.Default, un Model; se mide su
    -- caja y se pone una nube plana de espirales del mismo tamaño), (2) el estallido al romperse (Misc.MolotovExplosionEffects.Default, una Part) y (3) una estela al volar. Ademas el
    -- sonido de romperse del juego (rbxassetid 14812827928, el que crea Molotov.MolotovExplode) se cambia por un vidrio de Minecraft al azar (def.rotura).
    local ROJOS = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(214, 26, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 8, 12)),
    })
    local function texturasPocion()
        if POC.texturas then return POC.texturas end
        local t = {}
        for _, n in ipairs({ "pocion_remolino_1.png", "pocion_remolino_2.png", "pocion_aro.png" }) do
            local ok, id = pcall(cargarAsset, ruta(n))
            if ok and type(id) == "string" and id ~= "" then table.insert(t, id) end
        end
        POC.texturas = t
        if #t < 3 then anotar("POCION: faltan texturas (" .. #t .. " de 3) en la carpeta de Cielo") end
        return t
    end
    local function emisorPocion(padre, textura, c)
        local e = Instance.new("ParticleEmitter")
        e.Name = "CieloPocion"
        e.Texture = textura
        e.Color = ROJOS
        e.LightEmission = c.brillo or 0.4
        e.LightInfluence = 0
        e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, c.tam * 0.7), NumberSequenceKeypoint.new(0.3, c.tam), NumberSequenceKeypoint.new(1, c.tam * 0.8) })
        e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0.05), NumberSequenceKeypoint.new(0.75, 0.2), NumberSequenceKeypoint.new(1, 1) })
        e.Lifetime = NumberRange.new(c.vida[1], c.vida[2])
        e.Rate = c.rate or 0
        e.Speed = NumberRange.new(c.vel[1], c.vel[2])
        e.SpreadAngle = Vector2.new(c.abre or 180, c.abre or 180)
        e.Rotation = NumberRange.new(0, 360)
        e.RotSpeed = NumberRange.new(-60, 60)
        e.Acceleration = c.acel or Vector3.new(0, 0.3, 0)
        e.Drag = c.freno or 0
        e.EmissionDirection = Enum.NormalId.Top
        e.Enabled = c.activo ~= false
        e.Parent = padre
        return e
    end
    -- la nube de espirales sobre la zona de fuego: plana, del tamano de la zona del juego (su caja: lo mas fino es el alto)
    local function nubePocion(modelo)
        local tex = texturasPocion()
        if #tex == 0 then return end
        local cf, tam = modelo:GetBoundingBox()
        local mayor, menor = math.max(tam.X, tam.Y, tam.Z), math.min(tam.X, tam.Y, tam.Z)
        local radio = math.max(mayor / 2, 2)
        local base = Instance.new("Part")
        base.Name = "CieloPocionNube"
        base.Anchored, base.CanCollide, base.CanTouch, base.CanQuery, base.CastShadow = true, false, false, false, false
        base.Transparency = 1
        base.Size = Vector3.new(radio * 2, math.max(menor, 0.6), radio * 2)
        base.CFrame = CFrame.new(cf.Position)
        base.Parent = modelo
        local total = math.clamp(math.pi * radio * radio * 0.1, 18, 90)
        for i, t in ipairs(tex) do
            emisorPocion(base, t, { tam = i == 3 and 0.9 or 1.2, vida = { 2.2, 3.4 }, rate = total * (i == 3 and 0.3 or 0.35), vel = { 0, 0.5 }, abre = 180,
                acel = Vector3.new(0, 0.35, 0) })
        end
        local luz = Instance.new("PointLight")
        luz.Color, luz.Brightness, luz.Range = Color3.fromRGB(230, 40, 40), 1.2, math.clamp(radio, 8, 22)
        luz.Parent = base
        anotar(string.format("POCION: nube sobre la zona de fuego: caja %.1f x %.1f x %.1f (radio %.1f, %d particulas/s)", tam.X, tam.Y, tam.Z, radio, total))
    end
    -- el estallido al romperse: sale hacia todos lados y cae
    local function estallidoPocion(parte)
        local tex = texturasPocion()
        if #tex == 0 then return end
        local adj = Instance.new("Attachment")
        adj.Name = "CieloPocionEstallido"
        adj.Parent = parte
        for i, t in ipairs(tex) do
            local e = emisorPocion(adj, t, { tam = 1.5, vida = { 0.9, 1.6 }, rate = 0, vel = { 8, 20 }, abre = 180, acel = Vector3.new(0, -14, 0), freno = 2.5, activo = false, brillo = 0.5 })
            e:Emit(i == 3 and 14 or 26)
        end
        local luz = Instance.new("PointLight")
        luz.Color, luz.Brightness, luz.Range = Color3.fromRGB(255, 60, 50), 3, 16
        luz.Parent = adj
        task.spawn(function()
            for i = 1, 20 do
                task.wait(0.03)
                if not luz.Parent then return end
                luz.Brightness = 3 * (1 - i / 20)
            end
            luz:Destroy()
        end)
        anotar("POCION: estallido en " .. parte:GetFullName())
    end
    -- una estela de espirales pequenas mientras vuela
    estelaPocion = function(copia, skin)
        local def = moduloSkins.propia(skin)
        if not (def and def.efecto == "pocion") then return end
        local prim = copia:FindFirstChild("Primary")
        local tex = texturasPocion()
        if not (prim and #tex >= 2) then return end
        for i = 1, 2 do
            emisorPocion(prim, tex[i], { tam = 0.55, vida = { 0.5, 0.9 }, rate = 16, vel = { 0.3, 1.4 }, abre = 180, acel = Vector3.new(0, 0.2, 0) })
        end
    end
    -- lo que hay que cambiar cuando el juego pone un "Default" de fuego o de explosion del Molotov y la skin elegida es la pocion
    local function vestirPocionEfecto(hijo, tipo)
        esconder(hijo)
        if hijo:IsA("BasePart") then hijo.LocalTransparencyModifier = 1 end
        -- los sonidos del juego dentro del efecto (el del estallido, el crepitar del fuego) se callan
        for _, d in ipairs(hijo:GetDescendants()) do
            if d:IsA("Sound") then
                d.Volume = 0
                pcall(function() d:Stop() end)
            end
        end
        if tipo == "FireHitboxes" then
            nubePocion(hijo)
        elseif tipo == "estallido" or tipo == "MolotovExplosionEffects" then
            local parte = hijo:IsA("BasePart") and hijo or hijo:FindFirstChildWhichIsA("BasePart", true)
            estallidoPocion(hijo:IsA("BasePart") and hijo or parte or hijo)
            sonarVidrio(hijo:IsA("BasePart") and hijo or parte or SoundService)
        end
        -- tipo "suelo": el fuego visual del suelo (Ring, Ember, Smoke, Fire): solo se esconde, la nube de espirales ya la pone el FireHitboxes
    end
    local function esPocion(m)
        local nombre = m.elegidas and m.elegidas.Molotov
        local def = nombre and moduloSkins.propia(nombre)
        if def and def.efecto == "pocion" then return def end
        return nil
    end
    -- sonidos propios de la pocion: un archivo al azar de la lista (nunca el mismo dos veces seguidas), con volumen y tono un poco distintos cada vez.
    -- def.rotura = el vidrio de romperse (en el lugar del estallido), def.lanzar = el del arco al lanzarla. (El del juego dentro del "Default" del estallido se calla en
    -- vestirPocionEfecto; el 14812827928 que crea Molotov.MolotovExplode suena al LANZAR.)
    local function sonarLista(cfg, padre, etiqueta)
        local n = #cfg
        local i = 1
        if n > 1 then
            i = math.random(n - 1)
            if cfg.ultimo and i >= cfg.ultimo then i = i + 1 end
            cfg.ultimo = i
        end
        POC.assets = POC.assets or {}
        local archivo = cfg[i]
        local id = POC.assets[archivo]
        if not id then
            local ok, a = pcall(cargarAsset, ruta(archivo))
            if ok and type(a) == "string" and a ~= "" then id = a POC.assets[archivo] = a end
        end
        if not id then
            anotar("POCION: no pude cargar " .. tostring(archivo))
            return
        end
        local nuevo = Instance.new("Sound")
        nuevo.SoundId = id
        nuevo.Volume = (cfg.vol or 3) * (1 + (cfg.volazar or 0) * (math.random() * 2 - 1))
        nuevo.PlaybackSpeed = (cfg.tono or 1) + (cfg.azar or 0) * (math.random() * 2 - 1)
        nuevo:SetAttribute("CieloSonido", true)
        nuevo.Parent = padre or SoundService
        nuevo:Play()
        nuevo.Ended:Connect(function() nuevo:Destroy() end)
        task.delay(8, function() if nuevo.Parent then nuevo:Destroy() end end)
        anotar("POCION: " .. etiqueta .. " -> " .. tostring(archivo) .. " (vol " .. string.format("%.2f", nuevo.Volume) .. ")")
    end
    sonarVidrio = function(padre)
        local def = esPocion(buscar())
        if def and def.rotura then sonarLista(def.rotura, padre, "se rompe") end
    end
    sonarLanzar = function(skin)
        local def = moduloSkins.propia(skin)
        if def and def.efecto == "pocion" and def.lanzar then sonarLista(def.lanzar, SoundService, "lanzada") end
    end

    -- (v5.4) Efectos "Default": varias carpetas de Misc traen uno por skin y "Default" para el arma
    -- normal (el fuego del molotov, el hielo del Freeze Ray, el humo...). El juego clona el Default
    -- en workspace; si es tuyo (cerca de un proyectil tuyo, o de ti si acabas de usar algo) y tu skin
    -- tiene el suyo en esa carpeta, se esconde y va adentro el de la skin.
    local firmasDefault = nil -- carpeta de Misc -> cómo está armado su Default
    local function firma(x)
        local t = {}
        for _, d in ipairs(x:GetDescendants()) do table.insert(t, d.ClassName .. ":" .. d.Name) end
        table.sort(t)
        return x.ClassName .. "|" .. table.concat(t, ",")
    end
    local function carpetaDeDefault(hijo)
        local misc = carpeta("Misc")
        if not misc then return nil end
        if not firmasDefault then
            firmasDefault = {}
            for _, f in ipairs(misc:GetChildren()) do
                local d = f:FindFirstChild("Default")
                if d and f.Name ~= "FlamethrowerFlames" then firmasDefault[f] = firma(d) end
            end
        end
        local mia = firma(hijo)
        for f, s in pairs(firmasDefault) do
            if s == mia then return f end
        end
        return nil
    end

    local function cercaDeLoTuyo(pos)
        if POC.pos and os.clock() - POC.t < 8 and (POC.pos - pos).Magnitude < 45 then return true end
        for _, x in ipairs(propios) do
            if x.modelo.Parent and (x.modelo:GetPivot().Position - pos).Magnitude < 25 then return true end
        end
        local camara = workspace.CurrentCamera
        return camara ~= nil and os.clock() - ultimaAccion < 4 and (camara.CFrame.Position - pos).Magnitude < 30
    end

    local function vestirDefault(hijo, m)
        -- (v6.87) la pocion: el fuego visual del suelo (Model Default con Ring, Ember, Smoke, Fire, PointLight y 2 Sound) y el estallido (Part Default con un Attachment con SpikeyShards y
        -- un Sound) traen Sound, asi que no coinciden con la firma de ninguna carpeta de Misc: se reconocen por lo que tienen
        if esPocion(m) then
            local tipo
            if hijo:IsA("Model") and hijo:FindFirstChild("Fire", true) and hijo:FindFirstChild("Ring", true) and hijo:FindFirstChild("Ember", true) and hijo:FindFirstChildWhichIsA("Sound", true) then
                tipo = "suelo"
            elseif hijo:IsA("BasePart") and hijo:FindFirstChild("SpikeyShards", true) then
                tipo = "estallido"
            end
            if tipo then
                local pos1 = hijo:IsA("Model") and hijo:GetPivot().Position or hijo.Position
                if cercaDeLoTuyo(pos1) then
                    vestirPocionEfecto(hijo, tipo)
                    anotar("DEFAULT (" .. tipo .. ") -> pocion")
                else
                    anotar("DEFAULT (" .. tipo .. ") no es tuyo (pocion; dist " .. distanciaA(hijo) .. ")")
                end
                return
            end
        end
        local f = carpetaDeDefault(hijo)
        if not f then
            anotar("DEFAULT sin carpeta: " .. describir(hijo))
            return
        end
        -- (v6.87) la pocion de daño: el fuego del suelo y el estallido del Molotov se cambian por espirales rojas
        if (f.Name == "FireHitboxes" or f.Name == "MolotovExplosionEffects") and esPocion(m) then
            local pos0 = hijo:IsA("Model") and hijo:GetPivot().Position or hijo.Position
            if cercaDeLoTuyo(pos0) then
                vestirPocionEfecto(hijo, f.Name)
                anotar("DEFAULT de " .. f.Name .. " -> pocion")
            else
                anotar("DEFAULT de " .. f.Name .. " no es tuyo (pocion; dist " .. distanciaA(hijo) .. ")")
            end
            return
        end
        local skin
        for _, s in pairs(m.elegidas or {}) do
            if f:FindFirstChild(s) then
                skin = s
                break
            end
        end
        if not skin then return end
        local pos = hijo:IsA("Model") and hijo:GetPivot().Position or hijo.Position
        if not cercaDeLoTuyo(pos) then
            anotar("DEFAULT de " .. f.Name .. " no es tuyo (dist " .. distanciaA(hijo) .. ")")
            return
        end
        local copia = f[skin]:Clone()
        copia.Name = "CieloEfecto"
        -- lo del juego puede ir soldado a algo (el hielo, a quien congelaste): si se mueve, lo sigue
        local raiz = hijo:IsA("BasePart") and hijo or hijo.PrimaryPart or hijo:FindFirstChild("Primary")
        local suelto = raiz and raiz:IsA("BasePart") and not raiz.Anchored
        for _, d in ipairs(copia:IsA("BasePart") and { copia, table.unpack(copia:GetDescendants()) } or copia:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanCollide, d.CanTouch, d.CanQuery, d.Massless = false, false, false, true
                d.Anchored = not suelto
            elseif d:IsA("JointInstance") or d:IsA("WeldConstraint") then
                d:Destroy()
            end
        end
        if copia:IsA("Model") then
            copia:PivotTo(hijo:IsA("Model") and hijo:GetPivot() or hijo.CFrame)
        else
            copia.CFrame = hijo:IsA("Model") and hijo:GetPivot() or hijo.CFrame
        end
        if suelto then
            for _, d in ipairs(copia:IsA("BasePart") and { copia, table.unpack(copia:GetDescendants()) } or copia:GetDescendants()) do
                if d:IsA("BasePart") then
                    local w = Instance.new("WeldConstraint")
                    w.Part0, w.Part1 = raiz, d
                    w.Parent = d
                end
            end
        end
        copia.Parent = hijo
        esconder(hijo, copia)
        if hijo:IsA("BasePart") then hijo.LocalTransparencyModifier = 1 end
        emitir(copia)
        anotar("DEFAULT de " .. f.Name .. " -> " .. skin)
    end

    local function alAparecer(hijo)
        local m = buscar()
        if hijo.Name == "Default" and (hijo:IsA("Model") or hijo:IsA("BasePart")) then
            task.defer(function()
                if hijo.Parent then
                    local ok, fallo = pcall(vestirDefault, hijo, m)
                    if not ok then anotar("ERROR default: " .. tostring(fallo)) end
                end
            end)
            return
        end
        if os.clock() - ultimaAccion < 3 then
            anotar("NUEVO " .. describir(hijo) .. " dist=" .. distanciaA(hijo))
            task.delay(0.1, function()
                if hijo.Parent then anotar("   (0,1 s) " .. hijo.Name .. " dist=" .. distanciaA(hijo)) end
            end)
        end
        if hijo:IsA("Model") then
            local datos = m.modelos[hijo.Name]
            if not datos then return end
            anotar("CANDIDATO " .. hijo.Name .. " -> skin " .. datos.skin)
            local hechos = esconder(hijo) -- de entrada, para que no se vea ni un cuadro
            task.spawn(function()
                local ok, propio = pcall(esPropio, hijo)
                anotar("   ¿tuyo? " .. tostring(ok) .. " " .. tostring(propio) .. " dist=" .. distanciaA(hijo))
                if ok and propio and hijo.Parent then
                    local bien, fallo = pcall(vestirProyectil, hijo, datos)
                    anotar(bien and "   VESTIDO" or ("   ERROR al vestir: " .. tostring(fallo)))
                else
                    devolver(hechos)
                end
            end)
        elseif hijo:IsA("BasePart") then
            if m.rayos[hijo.Name] and disparando() then
                table.insert(pendientes, { parte = hijo, tipo = "rayo", dato = m.rayos[hijo.Name], t = os.clock() })
            elseif m.impactos[hijo.Name] and disparando() then
                -- donde pega el disparo (Exogun...): la plantilla de impacto de la skin
                local skin = m.impactos[hijo.Name]
                task.defer(function()
                    local adjunto = hijo.Parent and hijo:FindFirstChildWhichIsA("Attachment")
                    if adjunto then
                        local ok, fallo = pcall(cambiarExplosion, hijo, adjunto, skin, false, hijo.Name)
                        anotar(ok and ("IMPACTO -> " .. skin) or ("ERROR impacto: " .. tostring(fallo)))
                    end
                end)
            elseif hijo.Name == "TracerEffect" and m.bala and disparando() then
                table.insert(pendientes, { parte = hijo, tipo = "bala", dato = m.bala, t = os.clock() })
            elseif hijo.Name == "Part" and #propios > 0 then
                task.defer(function()
                    if hijo.Parent then pcall(revisarExplosion, hijo) end
                end)
            end
        end
    end

    -- (v6.25) La lanza que tiras y queda clavada: el juego clona el modelo de Assets.SpearTightropes con el nombre de tu skin de verdad
    -- y lo pone dentro de una Part "SpearTightrope" que cuelga de lo que golpeó (no directo en workspace). Si lo tiraste hace un
    -- momento (clic derecho), se viste con la skin elegida (la de Cielo, o la propia armada con sus piezas).
    local function vestirLanzaClavada(modelo)
        local m = buscar()
        local datos = m.modelos[modelo.Name]
        if not datos then return end
        if os.clock() - ultimaAccion > 5 then
            anotar("LANZA clavada " .. modelo.Name .. ": no es tuya (hace " .. string.format("%.1f", os.clock() - ultimaAccion) .. " s del último clic)")
            return
        end
        local bien, fallo = pcall(vestirProyectil, modelo, datos)
        anotar(bien and ("LANZA clavada " .. modelo.Name .. " -> " .. datos.skin) or ("ERROR lanza clavada: " .. tostring(fallo)))
    end

    local function iniciar()
        table.insert(conexiones, workspace.DescendantAdded:Connect(function(d)
            if d:IsA("Model") and d.Parent and d.Parent.Name == "SpearTightrope" then
                task.defer(function() if d.Parent then pcall(vestirLanzaClavada, d) end end)
            end
        end))
        table.insert(conexiones, workspace.ChildAdded:Connect(function(hijo)
            local ok, fallo = pcall(alAparecer, hijo)
            if not ok then anotar("ERROR " .. tostring(fallo)) end
        end))
        table.insert(conexiones, UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then ultimoDisparo = os.clock() end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2
                or TECLAS_TIRAR[i.KeyCode] then
                ultimaAccion = os.clock()
                anotar("ACCION " .. (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode.Name or i.UserInputType.Name))
            end
        end))
        local apretado = false
        table.insert(conexiones, RunService.RenderStepped:Connect(function()
            -- por si el juego se come el clic (en el explorador 19 casi no llegaban): mantenido también vale
            local ahora = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            if ahora then
                ultimoDisparo, ultimaAccion = os.clock(), os.clock()
                if not apretado then anotar("ACCION clic (mantenido)") end
            end
            apretado = ahora
            pcall(revisarPendientes)
        end))
        -- lo que aparece en el arma en la mano o la cámara al disparar (lanzallamas, Exogun...)
        local function mirarDentro(raiz)
            if not raiz then return end
            table.insert(conexiones, raiz.DescendantAdded:Connect(function(d)
                if os.clock() - ultimaAccion > 1.5 then return end
                if not d:GetFullName():find(jugador.Name .. " - ", 1, true) or d:FindFirstAncestor("CieloSkin") then return end
                if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                    anotar("   dentro: " .. d.ClassName .. " " .. d:GetFullName())
                end
            end))
        end
        task.spawn(function()
            local vms = workspace:WaitForChild("ViewModels", 30)
            mirarDentro(vms)
            mirarDentro(workspace.CurrentCamera)
            -- el fuego del lanzallamas: el juego pone sus partículas en la boca de TU arma al disparar;
            -- toman la apariencia de las de la skin (misma clase y nombre en FlamethrowerFlames)
            if vms then
                -- (v5.3) el juego clona en _muzzle las partículas de FlamethrowerFlames[Default] al SACAR el
                -- arma y las prende al disparar. Las de la skin se llaman distinto: van al lado, como copias
                -- que se prenden y apagan con su "Fire", y las del juego quedan invisibles
                local INVISIBLE = NumberSequence.new(1)
                local function vestirFuego(boca, llamas)
                    if boca:FindFirstChild("CieloFuego") then return end
                    local fuego = boca:FindFirstChild("Fire")
                    if not (fuego and fuego:IsA("ParticleEmitter")) then return end
                    local nombresJuego = {}
                    for _, e in ipairs((llamas.juego or boca):GetDescendants()) do
                        if e:IsA("ParticleEmitter") then nombresJuego[e.Name] = true end
                    end
                    nombresJuego.Fire, nombresJuego.Ember = true, true
                    for _, e in ipairs(boca:GetChildren()) do
                        if e:IsA("ParticleEmitter") and nombresJuego[e.Name] then e.Transparency = INVISIBLE end
                    end
                    local marca = Instance.new("Folder")
                    marca.Name = "CieloFuego"
                    marca.Parent = boca
                    local copias = {}
                    for _, e in ipairs(llamas.skin:GetDescendants()) do
                        if e:IsA("ParticleEmitter") then
                            local c = e:Clone()
                            c.Name = "CieloFuego_" .. e.Name
                            c.Enabled = false
                            c.Parent = boca
                            table.insert(copias, c)
                        end
                    end
                    local con
                    con = RunService.RenderStepped:Connect(function()
                        if not (fuego.Parent and boca.Parent) then
                            con:Disconnect()
                            return
                        end
                        local prendido = fuego.Enabled
                        for _, c in ipairs(copias) do
                            if c.Enabled ~= prendido then c.Enabled = prendido end
                        end
                    end)
                    anotar("LLAMA " .. #copias .. " de " .. llamas.skin.Name)
                end
                table.insert(conexiones, vms.DescendantAdded:Connect(function(d)
                    if not (d:IsA("ParticleEmitter") and d.Name == "Fire" and d.Parent and d.Parent.Name == "_muzzle") then return end
                    if d:FindFirstAncestor("CieloSkin") then return end
                    local fp = vms:FindFirstChild("FirstPerson")
                    if not (fp and d:IsDescendantOf(fp)) then return end
                    local vm = d
                    while vm.Parent ~= fp do vm = vm.Parent end
                    if vm.Name:sub(1, #jugador.Name + 3) ~= jugador.Name .. " - " then return end
                    -- se espera un poco: al sacar el arma, SKINS todavía no sabe cuál tienes en la mano
                    task.delay(0.8, function()
                        hechoEn = -10
                        local llamas = buscar().llamas
                        if llamas and d.Parent then
                            local ok, fallo = pcall(vestirFuego, d.Parent, llamas)
                            if not ok then anotar("ERROR fuego: " .. tostring(fallo)) end
                        end
                    end)
                end))
            end
            local misc = carpeta("Misc")
            local f = misc and misc:FindFirstChild("FlamethrowerFlames")
            if f then
                for _, h in ipairs(f:GetChildren()) do
                    local hijos = {}
                    for _, d in ipairs(h:GetDescendants()) do table.insert(hijos, d.ClassName .. ":" .. d.Name) end
                    anotar("FLAMES " .. h.ClassName .. " " .. h.Name .. " {" .. table.concat(hijos, ", ") .. "}")
                end
            else
                anotar("FLAMES no hay Misc.FlamethrowerFlames")
            end
            -- (v5.4) las carpetas con un efecto por skin ("Default" + nombres de skins) y las de Assets
            for _, h in ipairs(misc and misc:GetChildren() or {}) do
                if h:FindFirstChild("Default") then
                    local nombres = {}
                    for _, x in ipairs(h:GetChildren()) do table.insert(nombres, x.Name) end
                    anotar("MISC " .. h.Name .. ": " .. table.concat(nombres, " | "))
                end
            end
            local raizAssets = misc and misc.Parent
            for _, h in ipairs(raizAssets and raizAssets:GetChildren() or {}) do
                anotar("ASSETS " .. h.ClassName .. " " .. h.Name .. " (" .. #h:GetChildren() .. ")")
            end
        end)
        -- cada 5 s: lo que tiene elegido (si cambió) y el archivo
        task.spawn(function()
            local firma = nil
            while vivo do
                task.wait(5)
                local m = buscar()
                local partes = {}
                for base, d in pairs(m.modelos) do table.insert(partes, base .. "->" .. d.skin) end
                for base, s in pairs(m.rayos) do table.insert(partes, "rayo " .. base .. "->" .. s) end
                if m.bala then table.insert(partes, "bala " .. tostring(m.bala)) end
                table.sort(partes)
                local okC, c = pcall(moduloSkins.consultaProyectiles)
                local enMano = okC and c and (tostring(c.enMano) .. " (real " .. tostring(c.real) .. ")") or "?"
                local nueva = VERSION .. " | en la mano: " .. enMano .. " | busca: " .. table.concat(partes, ", ")
                if nueva ~= firma then
                    firma = nueva
                    anotar("ESTADO " .. nueva)
                end
                if registroNuevo then
                    registroNuevo = false
                    pcall(escribir, ruta("proyectiles_log.txt"), table.concat(registro, "\n"))
                end
            end
        end)
    end

    local function limpiar()
        for _, con in ipairs(conexiones) do con:Disconnect() end
        table.clear(conexiones)
    end

    return { iniciar = iniciar, limpiar = limpiar }
end)()

-- ============================================================================
-- CONTADOR DE DAÑO (debajo de la mira)
-- ============================================================================

local moduloContador = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- RENDIMIENTO (página ⚡ FPS)
-- ============================================================================

-- Un contador de FPS (con el promedio y el peor cuadro de los últimos segundos) y botones para
-- aligerar el juego: todo es como bajar los gráficos, solo en tu pantalla. Lo que se cambia se
-- fuerza (si el juego lo vuelve a poner, se vuelve a quitar) y se devuelve al apagarlo.
local moduloRendimiento = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- SUPER OPTIMIZADOR (página 🚀 OPTIMIZAR)
-- ============================================================================
-- Para servers llenos (20+ jugadores, arcade, free for all). Todo es solo en tu pantalla y se devuelve
-- al apagarlo: materiales lisos, menos detalle lejos, partículas que se apagan cuando están lejos o a
-- tus espaldas (con una lista para elegir cuáles sí y cuáles no) y algunos ajustes de gráficos.
-- La granada de humo y la niebla nunca se esconden de frente: taparlas dejaría ver a través de ellas.

local moduloOptimizador = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- JUGADORES: la gente del server con su @usuario exacto, para reportar bien
-- ============================================================================
-- Solo lee la lista de jugadores (la misma que ve cualquiera con Tab): no toca nada del juego.
-- Los que salen se quedan en la lista (el que hace trampa suele irse rápido) y los que marcas
-- con 🚩 se guardan en jugadores_marcados.txt: si vuelven a caer en tu server, avisa.

local moduloJugadores = NADA -- (modulo que no va en esta version)

-- ============================================================================
-- Atajos, teclas y arranque
-- ============================================================================

-- los atajos de la barra de la izquierda muestran si el cielo y los colores están prendidos
local function refrescarAtajos()
    local e = moduloCielo.estado()
    if not PF.secciones.cielo then return end -- (v6.97) ZENITH SKIN CHANGER no tiene cielo ni colores
    if not e.hayFoto then
        atajoCielo.Text = "☁️ Sin foto"
        atajoCielo:SetAttribute("Tip", "Cielo: todavia no hay foto (ve a la seccion Cielo y agrega una)")
        atajoCielo.BackgroundColor3 = C.panel2
        atajoCielo.TextColor3 = C.tenue
    else
        atajoCielo.Text = e.cielo and "☁️ Cielo ON" or "☁️ Cielo OFF"
        atajoCielo:SetAttribute("Tip", "Prende o apaga la foto de cielo")
        atajoCielo.BackgroundColor3 = e.cielo and C.acento or C.panel2
        atajoCielo.TextColor3 = e.cielo and C.oscuro or C.tenue
    end
    atajoColores.Text = e.colores and "🎨 Colores ON" or "🎨 Colores OFF"
    atajoColores:SetAttribute("Tip", "Prende o apaga los colores de los bloques")
    atajoColores.BackgroundColor3 = e.colores and C.acento or C.panel2
    atajoColores.TextColor3 = e.colores and C.oscuro or C.tenue
    local dano = PF.secciones.dano and moduloContador.activo()
    atajoDano.Text = dano and "🎯 Daño ON" or "🎯 Daño OFF"
    atajoDano:SetAttribute("Tip", "Prende o apaga el contador de daño")
    atajoDano.BackgroundColor3 = dano and C.acento or C.panel2
    atajoDano.TextColor3 = dano and C.oscuro or C.tenue
end
table.insert(alCambiarEstado, refrescarAtajos)
atajoCielo.MouseButton1Click:Connect(function() moduloCielo.alternar() end)
atajoColores.MouseButton1Click:Connect(function() moduloCielo.alternarColores() end)
atajoDano.MouseButton1Click:Connect(function() moduloContador.alternar() end)

-- todo como estaba el juego: el cielo (y con él el reflejo y la luz), los bloques, las armas y los
-- gráficos. El contador de daño y el de FPS son herramientas, no cambian cómo se ve el juego: quedan
conConfirmacion(atajoTodo, function()
    pcall(moduloCielo.restablecerCielo)
    pcall(moduloCielo.restablecerColores)
    pcall(moduloSkins.restablecer)
    pcall(moduloOptimizador.restablecer)
    pcall(moduloRendimiento.restablecer)
    refrescarAtajos()
    aviso("Todo como estaba: cielo del juego, sin reflejo, bloques y armas originales, gráficos del juego. El contador de daño sigue igual.")
end, "¿Seguro? Otra vez")

table.insert(conexionesUI, UserInputService.InputBegan:Connect(function(input)
    -- el clic para elegir bloque va antes que todo: los shooters marcan el clic como usado
    if moduloCielo.eligiendo() and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local posicion = UserInputService:GetMouseLocation()
        if not sobreVentana(posicion) then moduloCielo.elegirConClic(posicion) end
        return
    end
    -- no se mira si el juego ya usó la tecla: hay juegos que las marcan todas.
    -- Solo se ignora si estás escribiendo (chat, buscador, cuadro del color...)
    if UserInputService:GetFocusedTextBox() then return end
    if PF.secciones.cielo and input.KeyCode == TECLA_CIELO then
        moduloCielo.alternar()
    elseif PF.secciones.colores and input.KeyCode == TECLA_COLORES then
        moduloCielo.alternarColores()
    elseif TECLAS_VENTANA[input.KeyCode] or TECLAS_SKINS[input.KeyCode] then
        if abierta() then
            achicarVentana() -- a jugar: queda el iconito y el mouse vuelve al juego
        elseif TECLAS_SKINS[input.KeyCode] and paginas[paginaActual] ~= paginaSkins then
            abrirVentana("skins")
        else
            abrirVentana()
        end
    end
end))

-- si cambia el tamaño de la pantalla, la ventana y el iconito se acomodan
pcall(function()
    table.insert(conexionesUI, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(acomodar))
end)

botonMinimizar.MouseButton1Click:Connect(achicarVentana)

-- la × esconde todo (hasta el iconito): lo puesto se queda, y la tecla + la vuelve a abrir
botonCerrar.MouseButton1Click:Connect(function()
    estadoVentana = "oculta"
    refrescarVentana()
    aviso(string.format(traducir("Ventana oculta: la tecla %s la vuelve a abrir. Todo sigue puesto."), NOMBRE_TECLA))
end)

local function limpiar()
    vivo = false
    for _, con in ipairs(conexionesUI) do con:Disconnect() end
    table.clear(conexionesUI)
    mouseLibre(false)
    soltarRender("CieloTrabarMouse")
    pcall(moduloCielo.limpiar)
    pcall(moduloSkins.limpiar)
    pcall(moduloProyectiles.limpiar)
    pcall(moduloContador.limpiar)
    pcall(moduloOptimizador.limpiar)
    pcall(moduloRendimiento.limpiar)
    pcall(moduloJugadores.limpiar)
    gui:Destroy()
end

for _, tabla in ipairs(registros) do
    if type(tabla) == "table" then
        pcall(rawset, tabla, PF.claves[1], { Limpiar = limpiar, Version = VERSION })
    end
end

-- ============================================================================
-- CONFIGURACION (v7.00): idioma, tamaño de la ventana, tecla, arrancar achicada, avisos, y la ventana en su lugar
-- ============================================================================
do
    -- la tecla elegida (por defecto, la de cada perfil)
    local function aplicarTecla()
        for _, par in ipairs(TECLAS_ELEGIBLES) do
            if par[1] == CFG.tecla then
                NOMBRE_TECLA = par[2]
                table.clear(TECLAS_VENTANA)
                for _, k in ipairs(par[3]) do TECLAS_VENTANA[k] = true end
                if PERFIL == "completo" then
                    table.clear(TECLAS_SKINS)
                end
            end
        end
    end
    aplicarTecla()
    if CFG.achicada == "1" and not inicioAchicado then inicioAchicado = true end

    local desplazable = crear("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 5, ScrollBarImageColor3 = C.acento,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = paginaConfig,
    }, {
        crear("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
        crear("UIPadding", { PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
    })
    local orden = 0
    local function siguiente() orden = orden + 1 return orden end
    local function titulo(texto)
        crear("TextLabel", {
            LayoutOrder = siguiente(), Text = texto, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.acento, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Parent = desplazable,
        })
    end
    local function nota(texto)
        crear("TextLabel", {
            LayoutOrder = siguiente(), Text = texto, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.tenue, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = desplazable,
        })
    end
    -- una fila de botones para elegir uno: opciones = { { valor, texto }... }; alElegir(valor)
    local function selector(opciones, actual, alElegir, columnas)
        local filas = math.ceil(#opciones / (columnas or #opciones))
        local marco = crear("Frame", {
            LayoutOrder = siguiente(), Size = UDim2.new(1, 0, 0, filas * 38 - 4), BackgroundTransparency = 1, Parent = desplazable,
        })
        local botones = {}
        local function pintar(valor)
            for v, b in pairs(botones) do
                b.BackgroundColor3 = (v == valor) and C.acento or C.panel2
                b.TextColor3 = (v == valor) and C.oscuro or C.texto
            end
        end
        local porFila = columnas or #opciones
        for i, op in ipairs(opciones) do
            local fila, col = math.floor((i - 1) / porFila), (i - 1) % porFila
            local b = crear("TextButton", {
                Text = op[2], Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, BackgroundColor3 = C.panel2, TextColor3 = C.texto,
                Position = UDim2.new(col / porFila, col == 0 and 0 or 3, 0, fila * 38), Size = UDim2.new(1 / porFila, col == 0 and -3 or -6, 0, 34), Parent = marco,
            }, { esquina(12) })
            botones[op[1]] = b
            b.MouseButton1Click:Connect(function()
                pintar(op[1])
                alElegir(op[1])
            end)
        end
        pintar(actual)
        return pintar
    end
    local function boton(texto, alTocar)
        local b = crear("TextButton", {
            LayoutOrder = siguiente(), Text = texto, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, BackgroundColor3 = C.panel2, TextColor3 = C.texto,
            Size = UDim2.new(1, 0, 0, 36), Parent = desplazable,
        }, { esquina(12), trazo(C.linea, 1, 0) })
        b.MouseButton1Click:Connect(function() alTocar(b) end)
        return b
    end

    -- IDIOMA (obligatorio): al elegir uno la ventana se reinicia sola, ya en ese idioma, y vuelve a esta pagina
    titulo("Idioma")
    nota("Elige el idioma de la ventana. Se reinicia sola para aplicarlo.")
    selector(IDIOMAS, IDIOMA, function(valor)
        if valor == IDIOMA then return end
        CFG.idioma = valor
        guardarConfig()
        pcall(rawset, env, PF.globales .. "PestanaInicial", "config")
        task.defer(function()
            local ok, codigo = pcall(readfile, CARPETA .. "/cielo.lua")
            limpiar()
            if ok and type(codigo) == "string" and codigo ~= "" then
                local funcion = loadstring(codigo, "=cielo_reinicio")
                if funcion then funcion() end
            end
        end)
    end, 2)

    titulo("Ventana")
    nota("Tamaño de la ventana")
    selector({ { "90", "Pequeña" }, { "100", "Normal" }, { "115", "Grande" } }, tostring(math.floor(escalaUI.Scale * 100 + 0.5)), function(valor)
        CFG.escala = valor
        guardarConfig()
        escalaUI.Scale = tonumber(valor) / 100
        acomodar()
    end)
    nota("Tecla para abrir y achicar la ventana")
    local opcionesTecla = {}
    for _, par in ipairs(TECLAS_ELEGIBLES) do table.insert(opcionesTecla, { par[1], par[2] }) end
    local teclaActual = CFG.tecla
    if not teclaActual then
        for _, par in ipairs(TECLAS_ELEGIBLES) do
            if par[2] == NOMBRE_TECLA then teclaActual = par[1] end
        end
    end
    selector(opcionesTecla, teclaActual, function(valor)
        CFG.tecla = valor
        guardarConfig()
        aplicarTecla()
    end, 5)
    local botonAchicada, botonAvisos
    local function pintarSiNo(b, texto, activo)
        b.Text = texto .. ":  " .. traducir(activo and "ON" or "OFF")
        b.BackgroundColor3 = activo and C.acento or C.panel2
        b.TextColor3 = activo and C.oscuro or C.texto
    end
    botonAchicada = boton("", function(b)
        CFG.achicada = (CFG.achicada == "1") and "0" or "1"
        guardarConfig()
        pintarSiNo(b, "Empezar achicada al entrar a Rivals", CFG.achicada == "1")
    end)
    pintarSiNo(botonAchicada, "Empezar achicada al entrar a Rivals", CFG.achicada == "1")
    botonAvisos = boton("", function(b)
        CFG.avisos = (CFG.avisos == "0") and "1" or "0"
        guardarConfig()
        pintarSiNo(b, "Avisos en pantalla", CFG.avisos ~= "0")
    end)
    pintarSiNo(botonAvisos, "Avisos en pantalla", CFG.avisos ~= "0")
    boton("Poner la ventana en su lugar", function()
        geo.x, geo.y, geo.w, geo.h = nil, nil, nil, nil
        acomodar()
        guardarGeo()
    end)

    titulo("Acerca de")
    nota(PF.nombre .. " " .. VERSION)
    nota("Solo cosmético: sin aimbot, daño automático, velocidad, vuelo ni teletransporte. No envía nada a ningún lado.")
end

gui.Parent = padreGui()
borrarVentanasViejas(gui)
acomodar()
if pestanaInicial and paginas[pestanaInicial] then paginaActual = pestanaInicial end
if inicioAchicado then estadoVentana = "icono" end
moduloCielo.iniciar()
moduloSkins.iniciar()
moduloProyectiles.iniciar()
moduloContador.iniciar()
moduloRendimiento.iniciar()
pcall(moduloOptimizador.iniciar)
pcall(moduloJugadores.iniciar)
refrescarVentana()
refrescarAtajos()

local enRivals = ""
if moduloSkins.enRivals() then
    local cuantasSkins, cuantosWraps = moduloSkins.cuantas()
    enRivals = " " .. string.format(traducir("SKINS: %d skins y %d wraps."), cuantasSkins, cuantosWraps)
end
if inicioAchicado then
    aviso(VERSION .. traducir(" se abrió sola al entrar a Rivals (queda el iconito). ") .. string.format(traducir("La tecla %s abre la ventana."), NOMBRE_TECLA))
else
    local mensaje = string.format(traducir("La tecla %s achica la ventana a un iconito y la vuelve a abrir."), NOMBRE_TECLA)
    if PF.secciones.cielo then mensaje = mensaje .. " " .. traducir("F8 cielo, F6 colores.") end
    aviso(VERSION .. " " .. traducir("lista.") .. " " .. mensaje .. enRivals)
end

-- si desde la app llegó una foto o cambió el cielo elegido: leer archivos por Xeno puede trabar
-- un instante, así que se mira cada segundo solo con la ventana abierta en CIELO; si no, cada 15
task.spawn(function()
    local ultimaVez = 0
    while vivo do
        task.wait(1)
        local cada = (abierta() and paginaActual == "cielo") and 1 or 15
        if vivo and os.clock() - ultimaVez >= cada then
            ultimaVez = os.clock()
            local ok, fallo = pcall(moduloCielo.revisar)
            if not ok then warn("[Cielo] " .. tostring(fallo)) end
        end
    end
end)

task.spawn(function()
    while vivo do
        local ok, fallo = pcall(moduloSkins.revisar)
        if not ok then warn("[Skins] " .. tostring(fallo)) end
        task.wait(0.25)
    end
end)
