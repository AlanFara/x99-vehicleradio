<template>
   <div class="control-buttons">
      <div class="playlist">
         <button @click="displayEqualizer">
            <i class="fa-solid fa-sliders"></i>
         </button>
         <button @click="displayPlaylist">
            <i class="fa-solid fa-bars"></i>
         </button>
         <button @click="displayAddSong">
            <i class="fa-solid fa-plus"></i>
         </button>
      </div>

      <div class="buttons">
         <button @click="buttonBackward">
            <i class="fas fa-backward-step"></i>
         </button>
         <button :class="['play', { playing: isPlaying }]" @click="togglePause">
            <i :class="playButtonIcon"></i>
         </button>
         <button @click="buttonForward">
            <i class="fas fa-forward-step"></i>
         </button>
      </div>
      <div class="sound-control">
         <div class="icon">
            <i class="fas fa-volume-high"></i>
         </div>
         <div class="slider">
            <Slider v-model="sliderVolume" @input="updateVolume" :max="maxVolume" @change="syncVolume" />
         </div>
      </div>
   </div>
</template>

<script>
import Slider from '../Slider.vue';
import { mapState, mapGetters } from 'vuex'

export default {
   name: "ControlButtons",
   data: () => ({
      playing: false,
      sliderVolume: 0
   }),
   components: {
      Slider
   },
   methods: {
      togglePause() {
         this.$store.dispatch("togglePause", {})
      },
      displayPlaylist() {
         this.$store.dispatch("displayPlaylist")
      },
      displayAddSong() {
         this.$store.dispatch("displayAddSong")
      },
      displayEqualizer() {
         this.$store.dispatch("displayEqualizer")
      },
      updateVolume(vol) {
         this.$store.dispatch("updateVolume", {volume: vol})
      },
      syncVolume() {
         this.$store.dispatch("syncVolume")
      },
      buttonBackward() {
         this.$store.dispatch("buttonBackward")
      },
      buttonForward() {
         this.$store.dispatch("buttonForward")
      },
   },
   mounted() {
      this.$nextTick(() => {
         this.sliderVolume = this.volume
      })
   },
   watch: {
      volume() {
         this.sliderVolume = this.volume
      }
   },
   computed: {
      playButtonIcon() {
         if (this.isPlaying)
            return "fas fa-pause"
         else
            return "fas fa-play"
      },
      ...mapState({
         maxVolume: state => state.maxVolume,
      }),
      isPlaying() {
         return this.playerRadio.isPlaying
      },
      volume() {
         return this.playerRadio.volume
      },
      ...mapGetters([
         'playerRadio'
      ]),
   }
}
</script>

<style scoped lang="scss">
.control-buttons {
   display: grid;
   grid-template-columns: 0.5fr 1fr 0.5fr;
   gap: 1rem;
   margin-inline: 2rem;

   .playlist {
      display: flex;
      gap: 1rem;
      margin-block: auto;
      // button {
      //    background: #4c66a1;
      //    width: fit-content;
      //    height: fit-content;
      //    padding-inline: 1rem;
      //    padding-block: 0.3rem;
      //    border-radius: 0.3rem;
      // }
   }

   .buttons {
      display: flex;
      gap: 1rem;
      justify-content: center;
      font-size: 1.1rem;
      align-items: center;

      button {
         height: 2rem;
         width: 2rem;
         display: flex;
         flex-direction: column;
         align-items: center;
         justify-content: center;

         &.play {
            border-radius: 50%;
            height: 2.5rem;
            width: 2.5rem;
            font-size: 1.4rem;
            color: black;
            background: white;
            padding-left: 0.25rem;
         }

         &.play.playing {
            padding-left: 0;
         }
      }
   }

   .sound-control {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      justify-content: flex-end;

      .slider {
         display: flex;
         width: 10rem;
      }
   }
}
</style>