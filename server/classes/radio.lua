VehicleRadio = {}

function GenerateRandomString(length)
    local str = ""
    for i = 1, length do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

function VehicleRadio:create(netId, source)
    local this = {}
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    
    this.id = netId--GenerateRandomString(8)
    this.vehicle = vehicle
    this.source = source
    this.currentSong = ""
    this.playlist = {}
    this.volume = 15
    this.bassBoost = 0
    this.trebleBoost = 0
    this.currentTime = 0
    this.isPlaying = false

    self.__index = self
    return setmetatable(this, self)
end

function VehicleRadio:addSong(data, id)
    for k, v in pairs(self.playlist) do
        if v == id then return end
    end
    
    table.insert(self.playlist, {
        id = id,
        title = data.title,
        url = data.url,
    })

    if #self.playlist == 1 then
        self:playSong(id)
        self.isPlaying = true
    end
end

function VehicleRadio:playSong(id)
    self.currentSong = id
    self.currentTime = 0
    self.isPlaying = true
end

function VehicleRadio:syncVolume(volume)
    self.volume = volume
end

function VehicleRadio:syncBassBoost(bassBoost)
    self.bassBoost = bassBoost
end

function VehicleRadio:syncTrebleBoost(trebleBoost)
    self.trebleBoost = trebleBoost
end

function VehicleRadio:syncSeekTo(time)
    self.currentTime = time
end

function VehicleRadio:syncPause(isPlaying)
    self.isPlaying = isPlaying
end

function VehicleRadio:syncCurrentTime(time)
    self.currentTime = time
end