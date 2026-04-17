<template>
  <div class="app-wrapper">
    <sidebar class="sidebar-container" />
    <div class="main-container">
      <div class="fixed-header">
        <navbar />
      </div>
      <app-main />
    </div>
  </div>
</template>

<script>
import { Navbar, Sidebar, AppMain } from "./components";

export default {
  name: "Layout",
  components: {
    Navbar,
    Sidebar,
    AppMain,
  },
  methods: {},
};
</script>

<style scoped>
@import "~@/styles/variables.module.css";

.app-wrapper {
  position: relative;
  height: 100%;
  width: 100%;
}

.fixed-header {
  position: fixed;
  top: 0;
  right: 0;
  z-index: 9;
  width: calc(100% - var(--sideBarWidth));
  transition: width 0.28s;
}
</style>
