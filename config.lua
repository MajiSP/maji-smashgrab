Config = {}

-- Framework detection (auto-detected)
Config.Framework = 'auto' -- 'qb-core', 'qbox', 'esx', 'ox', 'auto'

-- Progress bar settings
Config.ProgressBar = {
    Duration = 5000, -- 5 seconds
    Label = 'Looting Vehicle...',
    useWhileDead = false,
    canCancel = true,
    disable = {
        car = true,
        move = true,
        combat = true,
    },
    anim = {
        dict = 'missheist_jewel',
        clip = 'smash_case'
    }
}

-- Vehicle item spawn settings
Config.VehicleItems = {
    BaseSpawnChance = 10, -- 10% base chance for ped vehicles to have items
    CheckDistance = 50.0, -- Distance to check vehicles
    OnlyPedVehicles = true, -- Only spawn items in ped vehicles, not player-owned
    MaxItemsPerVehicle = 1, -- Maximum number of item models per vehicle
    CleanupDistance = 100.0, -- Distance to cleanup mission entity status when no players nearby
}

-- Item models that spawn in vehicles with their own item pools
Config.ItemModels = {
    ['guncase'] = {
        model = 'prop_box_guncase_02a', -- 3D model hash/name
        spawnChance = 40, -- Chance this model appears when vehicle gets items
        items = {
            {item = 'money', chance = 45, min = 20, max = 200},
            {item = 'credit_card', chance = 30, min = 1, max = 2},
            {item = 'phone', chance = 25, min = 1, max = 1},
            {item = 'jewelry', chance = 15, min = 1, max = 1},
            {item = 'makeup', chance = 20, min = 1, max = 3},
        }
    },
    ['briefcase'] = {
        model = 'hei_p_attache_case_shut',
        spawnChance = 20,
        items = {
            {item = 'money', chance = 60, min = 100, max = 1000},
            {item = 'documents', chance = 40, min = 1, max = 3},
            {item = 'laptop', chance = 25, min = 1, max = 1},
            {item = 'usb_drive', chance = 30, min = 1, max = 2},
        }
    },
    ['backpack'] = {
        model = 'prop_michael_backpack',
        spawnChance = 35,
        items = {
            {item = 'phone', chance = 40, min = 1, max = 1},
            {item = 'wallet', chance = 35, min = 1, max = 1},
            {item = 'money', chance = 30, min = 50, max = 300},
            {item = 'snacks', chance = 50, min = 1, max = 5},
            {item = 'water_bottle', chance = 25, min = 1, max = 2},
        }
    },
    ['food_bag'] = {
        model = 'p_ld_bs_bag_01',
        spawnChance = 30,
        items = {
            {item = 'receipt', chance = 60, min = 1, max = 3},
            {item = 'clothing', chance = 40, min = 1, max = 2},
            {item = 'money', chance = 25, min = 10, max = 100},
            {item = 'gift_card', chance = 20, min = 1, max = 1},
        }
    },
    ['box'] = {
        model = 'prop_cs_package_01',
        spawnChance = 15,
        items = {
            {item = 'protein_bar', chance = 45, min = 1, max = 3},
            {item = 'water_bottle', chance = 40, min = 1, max = 2},
            {item = 'towel', chance = 30, min = 1, max = 1},
            {item = 'money', chance = 20, min = 20, max = 150},
        }
    }
}

-- Seats where items can spawn
Config.VehicleSeats = {
    [-1] = 'Driver Seat',
    [0] = 'Passenger Seat',
    [1] = 'Rear Left',
    [2] = 'Rear Right',
}

-- Notification settings
Config.Notifications = {
    Success = 'You found something valuable!',
    Nothing = 'You found nothing of value...',
    AlreadySearched = 'This vehicle has already been searched recently',
    TooFar = 'You moved too far away',
    Cancelled = 'You stopped searching',
}

-- Police settings
Config.Police = {
    AlertChance = 50, -- 50% chance to alert police
    RequiredCops = 0, -- Minimum cops online
    JobNames = {'police', 'sheriff'} -- Police job names
}

-- Vehicle-specific spawn chances (multipliers applied to base spawn chance)
Config.VehicleSpawnChances = {
    -- Luxury vehicles
    ['adder'] = 2.5,
    ['zentorno'] = 2.5,
    ['osiris'] = 2.0,
    ['t20'] = 2.0,
    ['entity2'] = 1.8,
    
    -- Sports cars
    ['carbonizzare'] = 1.5,
    ['comet2'] = 1.4,
    ['feltzer2'] = 1.3,
    
    -- SUVs
    ['baller'] = 1.8,
    ['cavalcade'] = 1.6,
    ['dubsta'] = 1.5,
    
    -- Sedans
    ['cognoscenti'] = 1.7,
    ['schafter2'] = 1.5,
    ['washington'] = 1.2,
    
    -- Economy cars
    ['blista'] = 0.8,
    ['dilettante'] = 0.7,
    ['panto'] = 0.6,
    ['asea'] = 0.7,
    
    -- Work vehicles
    ['benson'] = 0.3,
    ['mule'] = 0.2,
    ['phantom'] = 0.1,
}

-- Dispatch system settings
Config.Dispatch = {
    Enable = true, -- Enable dispatch alerts
    System = 'auto', -- 'auto', 'ps-dispatch', 'cd_dispatch', 'core_dispatch', 'linden_outlawalert', 'rcore_dispatch', 'qs-dispatch', 'custom'
    AlertCode = '10-31', -- Police code for vehicle break-in
    AlertMessage = 'Vehicle Break-in in Progress',
    BlipSettings = {
        sprite = 161, -- Blip sprite
        color = 1, -- Blip color (red)
        scale = 1.0, -- Blip scale
        time = 300000 -- Blip duration (5 minutes)
    }
}

-- Target system settings
Config.Target = {
    Icon = 'fas fa-hammer',
    Label = 'Smash & Grab',
    Distance = 2.0,
}
