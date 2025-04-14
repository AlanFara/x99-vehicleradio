<template>
   <div class="equalizer" v-if="displayEqualizer">
      <div class="item">
         <div class="name">
            Bass
         </div>
         <Slider orient="vertical" v-model="bassBoostValue" @input="updateBassBoost" @change="syncBassBoost" :min="bassRange.min" :max="bassRange.max" />
      </div>
      <div class="item">
         <div class="name">
            Treble
         </div>
         <Slider orient="vertical" v-model="trebleBoostValue" @input="updateTrebleBoost" @change="syncTrebleBoost" :min="trebleRange.min" :max="trebleRange.max" />
      </div>
   </div>
</template>

<script>
import Slider from './Slider.vue';
import { mapState, mapGetters } from 'vuex'

export default {
   components: {
      Slider
   },
   data: () => ({
      bassBoostValue: 0,
      trebleBoostValue: 0
   }),
   mounted() {
      this.$nextTick(() => {
         this.bassBoostValue = this.playerRadio.bassBoost
         this.trebleBoostValue = this.playerRadio.trebleBoost
      })
   },
   methods: {
      updateBassBoost(val) {
         this.$store.dispatch("updateBassBoost", {bassBoost: val})
      },
      updateTrebleBoost(val) {
         this.$store.dispatch("updateTrebleBoost", {trebleBoost: val})
      },
      syncBassBoost() {
         this.$store.dispatch("syncBassBoost")
      },
      syncTrebleBoost() {
         this.$store.dispatch("syncTrebleBoost")
      }
   },
   computed: {
      ...mapState({
         displayEqualizer: state => state.displayEqualizer,
         bassRange: state => state.bassRange,
         trebleRange: state => state.trebleRange,
      }),
      ...mapGetters([
         'playerRadio'
      ]),
   },
}
</script>

<style lang="scss" scoped>
.equalizer {
   display: flex;
   gap: 0.5rem;
   color: white;
   margin-left: 1rem;
   margin-block: 0.3rem;

   .item {
      display: flex;
      flex-direction: column;
   }
}
</style>