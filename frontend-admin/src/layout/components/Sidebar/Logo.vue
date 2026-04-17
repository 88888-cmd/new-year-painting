<template>
  <div class="sidebar-logo-container">
    <transition name="sidebarLogoFade">
      <router-link key="expand" class="sidebar-logo-link" to="/">
        <img src="@/assets/logo.png" class="sidebar-logo">
        <h1 class="sidebar-title">年画后台系统</h1>
      </router-link>
    </transition>
  </div>
</template>

<script>
export default {
  name: 'SidebarLogo',
  data() {
    return {
    }
  }
}
</script>

<style scoped>
.sidebarLogoFade-enter-active {
  transition: opacity 1.5s;
}

.sidebarLogoFade-enter,
.sidebarLogoFade-leave-to {
  opacity: 0;
}

.sidebar-logo-container {
  position: relative;
  width: 100%;
  height: 50px;
  line-height: 50px;
  background: #2b2f3a;
  text-align: center;
  overflow: hidden;
}

.sidebar-logo-container .sidebar-logo-link {
  height: 100%;
  width: 100%;
}

.sidebar-logo-container .sidebar-logo-link .sidebar-logo {
  width: 32px;
  height: 32px;
  vertical-align: middle;
  margin-right: 12px;
}

.sidebar-logo-container .sidebar-logo-link .sidebar-title {
  display: inline-block;
  margin: 0;
  color: #fff;
  font-weight: 600;
  line-height: 50px;
  font-size: 14px;
  vertical-align: middle;
}
</style>
