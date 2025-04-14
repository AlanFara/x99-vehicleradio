<template>
   <div class="modal">
      <div class="header">
         <span>
            Playlist
         </span>
         <button class="close" @click="closePlaylist">
            <i class="fas fa-times"></i>
         </button>
      </div>
      <div class="playlist-list">
         <div class="spacer" v-if="currentSong">
            Playing now
         </div>
         <button class="playlist-item playing" v-if="currentSong">
            <span>
               {{ getSongTitle(currentSong) }}
            </span>
         </button>
         <div class="spacer">
            Queue
         </div>
         <button class="playlist-item" v-for="id in getRemainingSongs" :key="id">
            <v-btn icon class="playlist-button" color="transparent" @click="playPlaylistAudio(id)">
               <v-icon>mdi-play</v-icon>
            </v-btn>
            <span>
               {{ getSongTitle(id) }}
            </span>
            <v-btn icon class="playlist-button delete" color="transparent" @click="removeFromPlaylist(id)">
               <v-icon>mdi-delete</v-icon>
            </v-btn>
         </button>
      </div>
   </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex'

export default {
   data: () => ({

   }),
   computed: {
      getRemainingSongs() {
         return this.playlist.filter(x => x.id !== this.currentSong).map(x => x.id)
      },
      ...mapState({
         displayPlaylist: state => state.displayPlaylist,
         displayAddSong: state => state.displayAddSong,
      }),
      ...mapGetters([
         'playerRadio'
      ]),
      playlist() {
         return this.playerRadio.playlist
      },
      currentSong() {
         return this.playerRadio.currentSong
      }
   },
   methods: {
      getSongTitle(id) {
         var title = this.getPlaylistAudio(id)?.title
         return title
      },
      getPlaylistAudio(id) {
         return this.playlist.find(x => x.id === id)
      },
      stopPlaying() {
         this.$store.dispatch("playAudio", false)
      },
      playPlaylistAudio(id) {
         this.$store.dispatch("syncPlaySong", {songId: id})
      },
      removeFromPlaylist(id) {
         this.$store.dispatch("removeFromPlaylist", id)
      },
      closePlaylist() {
         this.$store.dispatch("displayPlaylist", false)
      }
   },

   mounted() {
      this.$nextTick(() => {
         this.$store.dispatch("displayAddSong", false)
      })
   }
}
</script>

<style scoped lang="scss">
.header {
   display: flex;
   align-items: center;

   span {
      font-weight: 600;
      font-size: 1.8rem;
   }

   .close {
      font-size: 1.4rem;
      width: 3rem;
      margin-left: auto;
      text-align: center;
      height: 3rem;
      line-height: 3rem;
   }
}

.modal {
   background: rgb(51, 51, 82);
   color: white;
   position: absolute;
   inset: 0;
   margin: auto;
   height: 23rem;
   width: 50rem;
   border-radius: 0.4rem;
   display: flex;
   flex-direction: column;
   overflow: hidden;
   padding: 1rem;



   .playlist-list {
      overflow: auto;

      .spacer {
         font-weight: 600;
         font-size: 1.2rem;
         padding: 0.5rem 1rem;
      }

      .playlist-item {
         display: flex;
         align-items: center;
         gap: 1rem;
         text-align: left;
         height: 2.5rem;
         padding-inline: 1rem;
         width: -webkit-fill-available;

         background: rgba(92, 92, 138, 0.384);

         &:nth-of-type(2n) {
            background: transparent;
         }

         border-bottom: 1px solid rgba(255, 255, 255, 0.13);

         &:last-child {
            border: none;
         }

         .playlist-button {
            height: 2rem;
            width: 2rem;

            &.delete {
               margin-left: auto;
            }
         }
      }
   }
}
</style>