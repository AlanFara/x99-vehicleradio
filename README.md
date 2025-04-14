A lot of people were asking because we removed it from Tebex. You can use it as open source.

There is no support for this script. Items that need to be added are available in the file.

This script was last updated in 2024. There may be security issues or it may not work. You are solely responsible.



| Export Function                                                             | Description                                          |
| --------------------------------------------------------------------------- | ---------------------------------------------------- |
| `x99-vehicleradio:client:openRadio`                                         | This function shows vehicleradio menu                |


## First of all, you need to install youtube-dl-exec in your package, for this you need to open CMD to the location where FXServer.exe is located and type `npm i youtube-dl-exec` and install it. Otherwise the script will not work.



https://user-images.githubusercontent.com/42780579/268454383-05874e3c-e479-4029-888a-ec864082cfd2.mp4




If you want to do it using an item, follow this.


```lua
QBCore.Functions.CreateUseableItem('vehicleradio', function(source)
    TriggerClientEvent("x99-vehicleradio:client:openRadio", source)
end)
```

^ add this to server side.


```lua
{
   id = 'openradio',
   title = 'Open Radio',
   icon = 'car-side',
   type = 'client',
   event = 'x99-vehicleradio:client:openRadio',
   shouldClose = true
}
```

^ For Radial Menu


If you are using ESX and want to add item for Vehicle Radio

```lua
ESX.RegisterUsableItem('vehicleradio', function(source)
    TriggerClientEvent("x99-vehicleradio:client:openRadio", source)
end)
```

If you need help or something hit us on `Discord` https://discord.gg/6V9QEucvwx
