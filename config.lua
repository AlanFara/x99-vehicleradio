Config = {
    maxVolume = 70, -- 0 - 100

    useStereo = true, -- activates stereo effect
    useLPF = true, -- activates low pass filter when the doors or windows are closed

    muteRadioCommand = 'vehicleradio:toggle', -- command to mute/unmute the radio | set to false to disable

    bassRange = { -- bass range
        min = -10, -- min bass level
        max = 22, -- max bass level
    },
    trebleRange = { -- treble range
        min = -10, -- min treble level
        max = 22, -- max treble level
    },
}