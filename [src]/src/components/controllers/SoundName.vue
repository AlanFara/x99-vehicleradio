<template>
   <div class="sound-name">
      <div class="name" v-if="playerRadio">
         {{ playerRadio.title }}
      </div>
      <div class="error" v-if="error">
         {{ playerRadio.error }}
      </div>
   </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex'

export default {
   computed: {
      ...mapGetters({
         playerRadio: 'playerRadio',
      }),
   }
}
</script>

<style scoped lang="scss">
.sound-name {
   text-align: center;
   .name {
      font-size: 1.1rem;
      font-weight: 500;
   }
   
   .error {
      color: red;
   }
}
</style>