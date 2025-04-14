import { createStore } from 'vuex'
import axios from "axios";
let DEBUG = false

let resourceName = "x99-vehicleradio"

if (window.GetParentResourceName) {
   resourceName = GetParentResourceName()
}

const post = (url, data) => {
   try {
      return fetch(`http://${resourceName}/${url}`, {
         method: "POST",
         body: JSON.stringify(data),
         headers: {
            "Content-Type": "application/json",
         },
      }).then((response) => response && response.json());
   } catch (error) {
      // debuglog("post error", error);
   }
};

const debuglog = (...args) => {
   if (DEBUG) {
      console.log(...args)
   }
}

const validQueryDomains = new Set([
   'youtube.com',
   'www.youtube.com',
   'm.youtube.com',
   'music.youtube.com',
   'gaming.youtube.com',
]);
const urlRegex = /^https?:\/\//;
const getVideoID = str => {
   if (validateID(str)) {
      return str;
   } else if (urlRegex.test(str.trim())) {
      return getURLVideoID(str);
   } else {
      throw Error(`No video id found: ${str}`);
   }
};

const idRegex = /^[a-zA-Z0-9-_]{11}$/;
const validateID = id => idRegex.test(id.trim());


const validPathDomains = /^https?:\/\/(youtu\.be\/|(www\.)?youtube\.com\/(embed|v|shorts)\/)/;
const getURLVideoID = link => {
   const parsed = new URL(link.trim());
   let id = parsed.searchParams.get('v');
   if (validPathDomains.test(link.trim()) && !id) {
      const paths = parsed.pathname.split('/');
      id = parsed.host === 'youtu.be' ? paths[1] : paths[2];
   } else if (parsed.hostname && !validQueryDomains.has(parsed.hostname)) {
      throw Error('Not a YouTube domain');
   }
   if (!id) {
      throw Error(`No video id found: "${link}"`);
   }
   id = id.substring(0, 11);
   if (!validateID(id)) {
      throw TypeError(`Video id (${id}) does not match expected ` +
         `format (${idRegex.toString()})`);
   }
   return id;
};


const store = createStore({
   state: {
      globalRadios: [],
      playerRadioId: null,

      vehiclesInScope: [],

      displayRadio: false,
      displayPlaylist: false,
      displayAddSong: false,
      displayEqualizer: false,

      maxVolume: 50,
      bassRange: { min: -10, max: 22 },
      trebleRange: { min: -10, max: 22 },
      progress: "",
   },
   actions: {
      getRadioById({ state }, id) {
         return state.globalRadios.find(radio => radio.id == id)
      },

      displayPlaylist({ state }, display) {
         state.displayPlaylist = display == null ? !state.displayPlaylist : display
      },
      displayAddSong({ state }, display) {
         state.displayAddSong = display == null ? !state.displayAddSong : display
      },
      displayEqualizer({ state }, display) {
         state.displayEqualizer = display == null ? !state.displayEqualizer : display
      },

      async addSongToPlaylist({ state }, { url }) {
         const id = getVideoID(url)
         state.progress = "Processing...";
         post("addSong", {
            id
         })
      },

      async createAudioSource({ state, dispatch }, { radioId, songId }) {
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[createAudioSource] Radio not found", radioId, radio);
         const song = radio.playlist.find(song => song.id == songId);
         // if (!song) return debuglog("[createAudioSource] Song not found", songId, radio);
         // if (!radio.isPlaying) return debuglog("[createAudioSource] Radio is not playing", radioId, radio);

         if (!radio.audioContext) {
            radio.audioContext = new AudioContext();
            debuglog("[createAudioSource] AudioContext created", radio.audioContext);
         }

         if (!radio.audioElement) {
            radio.audioElement = document.createElement("audio", { id: `audio-${radioId}` });
            radio.audioElement.crossOrigin = "anonymous";
            radio.audioElement.preload = "metadata";
            radio.audioElement.volume = 0;
            radio.audioElement.loop = false;
            radio.audioElement.autoplay = false;
            radio.audioElement.controls = false;
            radio.audioElement.id = `audio-${radioId}`;
            if (song) {
               radio.audioElement.src = song.url;
            }

            debuglog("[createAudioSource] AudioElement created", radio.audioElement, song, radio.audioElement.volume);
         }

         if (!radio.sourceNode) {
            radio.sourceNode = radio.audioContext.createMediaElementSource(radio.audioElement);
            debuglog("[createAudioSource] SourceNode created", radio.sourceNode);
         }

         const audio = await dispatch("createFilters", { radioId });

         audio.addEventListener('timeupdate', function () {
            radio.currentTime = audio.currentTime
            post("timeupdate", { time: radio.currentTime, radioId: radioId })
         });

         radio.currentSong = songId
         audio.addEventListener('loadedmetadata', async function () {
            const newSong = radio.playlist.find(song => song.id == radio.currentSong);
            audio.volume = radio.volume / 100
            radio.title = newSong.title
            radio.duration = audio.duration

            dispatch("syncPause", { isPlaying: radio.isPlaying, radioId: radioId })
            debuglog("[createAudioSource] Song loaded", radio, newSong, radio.currentSong);
            audio.currentTime = radio.currentTime
         });

         audio.addEventListener('ended', function () {
            debuglog("[createAudioSource] Song ended", radio);
            dispatch("syncPause", { isPlaying: false, radioId: radioId })
            dispatch("playNextSong", { radioId: radioId })
         });

         audio.addEventListener('pause', function () {
            radio.isPlaying = false
         });

         audio.addEventListener('play', function () {
            radio.isPlaying = true
         });
      },

      updateVolume({ state }, { volume, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[updateVolume] Radio not found", radioId, radio);

         radio.volume = volume
         if (radio.audioElement) {
            radio.audioElement.volume = (volume / 100) * radio.distancedVolume
         }
      },
      updateBassBoost({ state }, { bassBoost, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[updateBassBoost] Radio not found", radioId, radio);

         if (radio.bassFilter) {
            radio.bassFilter.gain.value = bassBoost
         } else {
            debuglog("[updateBassBoost] BassFilter not found", radioId, radio);
         }

         radio.bassBoost = bassBoost
      },
      updateTrebleBoost({ state }, { trebleBoost, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[updateTrebleBoost] Radio not found", radioId, radio);
         if (radio.trebleFilter) {
            radio.trebleFilter.gain.value = trebleBoost
         } else {
            debuglog("[updateTrebleBoost] TrebleFilter not found", radioId, radio);
         }

         radio.trebleBoost = trebleBoost
      },
      updateCurrentTime({ state }, { time, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[updateCurrentTime] Radio not found", radioId, radio);
         if (time > radio.duration) return debuglog("[updateCurrentTime] Time is bigger than duration", time, radio.duration);
         if (time < 0) return debuglog("[updateCurrentTime] Time is smaller than 0", time, radio.duration);
         if (time == Infinity) return debuglog("[updateCurrentTime] Time is Infinity", time, radio.duration);

         radio.currentTime = time
         if (radio.audioElement) {
            radio.audioElement.currentTime = time
         }
      },

      togglePause({ state }, { play, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[togglePause] Radio not found", radioId, radio);
         radio.isPlaying = play != null ? play : !radio.isPlaying

         debuglog("play", play, radio.isPlaying)
         // if (radio.isPlaying) {
         //    radio.audioElement.pause()
         // } else {
         //    radio.audioElement.play()
         // }

         post("togglePause", { isPlaying: radio.isPlaying })
      },

      playSong({ state }, { radioId, songId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[playSong] Radio not found", radioId, radio);
         const song = radio.playlist.find(song => song.id == songId);
         if (!song) return debuglog("[playSong] Song not found", song, songId, radio);
         state.progress = "";
         radio.currentSong = songId;
         radio.audioElement.src = song.url;
         radio.audioElement.volume = 0;
         radio.audioElement.play();
      },

      syncVolume({ state }) {
         const radio = state.globalRadios.find(radio => radio.id == state.playerRadioId)
         if (!radio) return debuglog("[syncVolume] Radio not found", state.playerRadioId, radio);

         post("syncVolume", { volume: radio.volume })
      },
      syncBassBoost({ state }) {
         const radio = state.globalRadios.find(radio => radio.id == state.playerRadioId)
         if (!radio) return debuglog("[syncBassBoost] Radio not found", state.playerRadioId, radio);

         post("syncBassBoost", { bassBoost: radio.bassFilter.gain.value })
      },
      syncTrebleBoost({ state }) {
         const radio = state.globalRadios.find(radio => radio.id == state.playerRadioId)
         if (!radio) return debuglog("[syncTrebleBoost] Radio not found", state.playerRadioId, radio);

         post("syncTrebleBoost", { trebleBoost: radio.trebleFilter.gain.value })
      },
      syncSeekTo({ state }, { time, radioId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[updateCurrentTime] Radio not found", radioId, radio);

         if (time > radio.duration) return debuglog("[updateCurrentTime] Time is bigger than duration", time, radio.duration);
         if (time < 0) return debuglog("[updateCurrentTime] Time is smaller than 0", time, radio.duration);
         if (time == Infinity) return debuglog("[updateCurrentTime] Time is Infinity", time, radio.duration);

         post("syncSeekTo", { time })
      },
      syncPause({ state }, { radioId, isPlaying, time }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[syncPause] Radio not found", radioId, radio);

         radio.isPlaying = isPlaying
         if (radio.isPlaying) {
            radio.audioElement.play()
            radio.audioElement.volume = 0;
         } else {
            radio.audioElement.pause()
         }

         if (time) {
            radio.audioElement.currentTime = time
         }
      },


      syncPlaySong({ state, dispatch }, { radioId, songId }) {
         radioId = radioId || state.playerRadioId
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[syncPlaySong] Radio not found", radioId, radio);
         const song = radio.playlist.find(song => song.id == songId);
         if (!song) return debuglog("[syncPlaySong] Song not found", songId, radio);
         state.progress = "";
         // if (radio.audioElement) {
         //    radio.audioElement.src = "data:audio/mp3;base64," + song.base64;
         //    radio.audioElement.play();
         // } else {
         //    dispatch("createAudioSource", { radioId, songId })
         // }

         post("playSong", { radioId, songId })
      },


      buttonBackward({ state, dispatch }) {
         const radio = state.globalRadios.find(radio => radio.id == state.playerRadioId)
         if (!radio) return debuglog("[buttonBackward] Radio not found", state.playerRadioId, radio);

         if (radio.audioElement.currentTime > 5) {
            dispatch("syncSeekTo", { time: 0 })
         } else {
            const index = radio.playlist.findIndex(song => song.id == radio.currentSong)
            if (index == -1) return debuglog("[buttonBackward] Song not found", radio.currentSong, radio.playlist);
            if (!radio.playlist[index - 1]) return debuglog("[buttonBackward] Song not found", radio.currentSong, radio.playlist);

            dispatch("playSong", { radioId: state.playerRadioId, songId: radio.playlist[index - 1].id })
         }
      },

      buttonForward({ state }) {
         const radio = state.globalRadios.find(radio => radio.id == state.playerRadioId)
         if (!radio) return debuglog("[buttonForward] Radio not found", state.playerRadioId, radio);

         const index = radio.playlist.findIndex(song => song.id == radio.currentSong)
         if (index == -1) return debuglog("[buttonForward] Song not found", radio.currentSong, radio.playlist);

         post("playSong", { radioId: state.playerRadioId, songId: radio.playlist[index + 1].id })
      },

      createFilters({ state }, { radioId }) {
         const radio = state.globalRadios.find(radio => radio.id == radioId)
         if (!radio) return debuglog("[createFilters] Radio not found", radioId, radio);

         const audio = radio.audioElement;
         const source = radio.sourceNode;
         const context = radio.audioContext;

         const bassFilter = context.createBiquadFilter();
         bassFilter.type = "lowshelf";
         bassFilter.frequency.value = 60;
         bassFilter.gain.value = radio.bassBoost;
         radio.bassFilter = bassFilter;
         debuglog("[createAudioSource] BassFilter created", bassFilter);

         const trebleFilter = context.createBiquadFilter();
         trebleFilter.type = "highshelf";
         trebleFilter.frequency.value = 10000;
         trebleFilter.gain.value = radio.trebleBoost;
         radio.trebleFilter = trebleFilter;
         debuglog("[createAudioSource] TrebleFilter created", trebleFilter);

         const stereoPanner = context.createStereoPanner();
         stereoPanner.pan.value = radio.stereoPan;
         radio.stereoPanner = stereoPanner;
         debuglog("[createAudioSource] StereoPanner created", stereoPanner);

         const LPFilter = context.createBiquadFilter();
         LPFilter.type = "lowpass";
         LPFilter.frequency.value = 20000;
         radio.LPFilter = LPFilter;

         source.connect(bassFilter);
         bassFilter.connect(trebleFilter);
         trebleFilter.connect(stereoPanner);
         stereoPanner.connect(LPFilter);
         LPFilter.connect(context.destination);

         return audio;
      }
   },
   getters: {
      playerRadio(state) {
         if (!state.playerRadioId) return null
         return state.globalRadios.find(radio => radio.id == state.playerRadioId)
      }
   }
})

window.addEventListener('message', async (event) => {
   const data = event.data;
   const state = store.state;
   const dispatch = store.dispatch;

   if (data.type != "updatePosition" && data.type != "updatePositionFar") {
      // debuglog("data", data)
   }

   if (data.type === "display") {
      state.displayRadio = data.display
   }

   if (data.type === "register") {
      state.playerRadioId = data.radio
   }

   if (data.type === "unregister") {
      const radio = state.globalRadios.find(radio => radio.id == data.radio)
      if (!radio) return debuglog("[unregister] Radio not found", data.radio, radio);

      radio.audioElement.pause()
      radio.audioElement.src = ""
      radio.audioElement.volume = 0
      radio.audioElement = null

      state.globalRadios = state.globalRadios.filter(radio => radio.id != data.radio)

      if (state.playerRadioId == data.radio) {
         state.playerRadioId = null
      }
   }

   if (data.type === "update") {
      let radios = {}
      for (const [key, value] of Object.entries(data.radios)) {
         radios[key] = value
      }
      state.globalRadios = radios
   }

   if (data.type === "playGlobal") {
      // dispatch("createAudioSource", data)
   }

   if (data.type === "syncGlobal") {
      const rId = data.args.netId

      if (data.key === "addSong") {
         const id = data.args.songId
         const radio = await dispatch("getRadioById", rId)
         if (radio) {
            if (radio.playlist.find(song => song.id == id)) {
               debuglog("[addSong] song already exists", id); return;
            }

            const mp3 = {
               title: data.args.title,
               url: data.args.url,
               id: id,
            }

            radio.playlist.push(mp3)

            if (radio.playlist.length === 1) {
               if (state.vehiclesInScope.includes(rId)) {
                  dispatch("playSong", { songId: mp3.id, radioId: rId })
               }
            }



            store.state.progress = "";
         }
      }

      if (data.key == "registerRadio") {
         if (await dispatch("getRadioById", rId)) {
            debuglog("[registerRadio] radio already exists", rId); return;
         }

         state.globalRadios.push({
            id: rId,
            playlist: [],
            currentSong: null,
            currentTime: 0,
            isPlaying: false,
            volume: 15,
            distancedVolume: 1,
            title: "",
            duration: 0,
            audioContext: null,
            audioElement: null,
            sourceNode: null,
            bassBoost: 0,
            trebleBoost: 0,
            stereoPan: 0,
            bassFilter: null,
            trebleFilter: null,
            stereoPanner: null,
            LPFilter: null,
            progress: "",
         })

         debuglog("[registerRadio] radio registered", rId)
      }

      if (data.key == "syncVolume") {
         dispatch("updateVolume", { volume: data.args.volume, radioId: rId })
      }

      if (data.key == "syncBassBoost") {
         dispatch("updateBassBoost", { bassBoost: data.args.bassBoost, radioId: rId })
      }

      if (data.key == "syncTrebleBoost") {
         dispatch("updateTrebleBoost", { trebleBoost: data.args.trebleBoost, radioId: rId })
      }

      if (data.key == "syncSeekTo") {
         dispatch("updateCurrentTime", { time: data.args.time, radioId: rId })
      }

      if (data.key == "syncPause") {
         dispatch("syncPause", { isPlaying: data.args.isPlaying, time: data.args.time, radioId: rId })
      }

      if (data.key == "playSong") {
         dispatch("playSong", { songId: data.args.songId, radioId: rId })
      }
   }

   if (data.type == "updatePosition") {
      const radio = await dispatch("getRadioById", data.netId)
      if (radio) {
         radio.leftBalance = data.leftBalance.toFixed(4)
         radio.rightBalance = data.rightBalance.toFixed(4)
         radio.distancedVolume = data.volume

         const steropan = (radio.leftBalance - radio.rightBalance) / 5
         if (radio.stereoPanner) {
            radio.stereoPan = -steropan
            radio.stereoPanner.pan.value = radio.stereoPan
         }

         if (radio.audioElement) {
            radio.audioElement.volume = (radio.volume / 100) * radio.distancedVolume
         }

         if (data.LPFValue) {
            const value = data.LPFValue
            // value = min 0, max 0.5
            // calculate percent
            const valuePercent = ((value * 100) / 0.5) / 70
            const freq = Math.min(20000 / valuePercent, 20000)

            if (radio.LPFilter) {
               radio.LPFilter.frequency.value = freq
            }
         } else if (radio.LPFilter) {
            radio.LPFilter.frequency.value = 20000
         }
      }
   }

   if (data.type == "syncRadios") { // disabled
      const radios = data.radios
      debuglog("SYNC [registerRadio] radios", radios)
      for (let radioId in radios) {
         if (Object.hasOwnProperty.call(radios, radioId)) {
            radioId = parseInt(radioId)
            const radio = radios[radioId];
            state.globalRadios.push({
               id: radioId,
               playlist: radio.playlist || [],
               currentSong: radio.currentSong || "",
               currentTime: radio.currentTime || "",
               isPlaying: radio.isPlaying || false,
               volume: radio.volume || 15,
               distancedVolume: 1,
               title: radio.title || "",
               duration: radio.duration || 0,
               audioContext: null,
               audioElement: null,
               sourceNode: null,
               bassBoost: radio.bassBoost || 0,
               trebleBoost: radio.trebleBoost || 0,
               stereoPan: 0,
               bassFilter: null,
               trebleFilter: null,
               stereoPanner: null,
               LPFilter: null,
               progress: "",
            })
            debuglog("SYNC [registerRadio] radio registered", radio, state.globalRadios)

            debuglog("[registerRadio] radio synced", radioId)
         }
      }
   }

   if (data.type == "config") {
      state.maxVolume = data.maxVolume
      state.bassRange = data.bassRange
      state.trebleRange = data.trebleRange
   }

   if (data.type == "debug") {
      DEBUG = data.debug
   }

   if (data.type == "vehicleEnteredScope") {
      if (!state.vehiclesInScope.includes(data.netId)) {
         state.vehiclesInScope.push(data.netId)
      }
      const radio = data.data
      state.globalRadios.push({
         id: data.netId,
         playlist: radio.playlist || [],
         currentSong: radio.currentSong || "",
         currentTime: radio.currentTime || "",
         isPlaying: radio.isPlaying || false,
         volume: radio.volume || 15,
         distancedVolume: 1,
         title: radio.title || "",
         duration: radio.duration || 0,
         audioContext: null,
         audioElement: null,
         sourceNode: null,
         bassBoost: radio.bassBoost || 0,
         trebleBoost: radio.trebleBoost || 0,
         stereoPan: 0,
         bassFilter: null,
         trebleFilter: null,
         stereoPanner: null,
         LPFilter: null,
         progress: "",
      })

      if (radio) {
         dispatch("createAudioSource", {
            radioId: data.netId,
            songId: radio.currentSong
         })

         const syncedRadio = await dispatch("getRadioById", data.netId)
         if (syncedRadio && syncedRadio.audioElement) {
            debuglog("[vehicleEnteredScope] radio synced", syncedRadio, radio)

            dispatch("syncPause", {
               isPlaying: radio.isPlaying,
               radioId: data.netId
            })

            dispatch("updateVolume", {
               volume: radio.volume,
               radioId: data.netId
            })

            dispatch("updateBassBoost", {
               bassBoost: radio.bassBoost,
               radioId: data.netId
            })

            dispatch("updateTrebleBoost", {
               trebleBoost: radio.trebleBoost,
               radioId: data.netId
            })

            dispatch("updateCurrentTime", {
               time: radio.currentTime,
               radioId: data.netId
            })
         }
      }
   }

   if (data.type == "vehicleLeftScope") {
      state.vehiclesInScope = state.vehiclesInScope.filter(vehicle => vehicle != data.netId)

      const radio = await dispatch("getRadioById", data.netId)
      if (radio) {
         if (radio.audioElement) {
            radio.audioElement.pause()
            radio.audioElement.src = ""
            radio.audioElement.volume = 0
            radio.audioElement = null
         }
         if (radio.audioContext) {
            radio.audioContext.close()
            radio.audioContext = null
         }
         if (radio.sourceNode) {
            radio.sourceNode = null
         }
      }
   }
});

window.addEventListener("keydown", (e) => {
   if (e.key == "Escape") {
      post("display", {
         display: false
      })
      store.state.displayPlaylist = false
      store.state.displayAddSong = false
   }
})

window.onload = () => {
   debuglog("onload")
   post("requestRadioSync")
}

export default store