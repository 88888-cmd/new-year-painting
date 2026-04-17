<template>
  <div class="navbar">
    <breadcrumb class="breadcrumb-container" />

    <div class="right-menu">
      <el-dropdown class="avatar-container right-menu-item hover-effect" trigger="click">
        <div class="avatar-wrapper">
          <el-avatar :size="40" icon="el-icon-user-solid" class="user-avatar" shape="square" />
          <i class="el-icon-caret-bottom" />
        </div>
        <el-dropdown-menu slot="dropdown">
          <router-link to="/">
            <el-dropdown-item>
              首页
            </el-dropdown-item>
          </router-link>
          <router-link to="/editPassword">
            <el-dropdown-item>
              修改密码
            </el-dropdown-item>
          </router-link>
          <el-dropdown-item divided @click.native="logout">
            <span style="display:block;">退出登录</span>
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import Breadcrumb from '@/components/Breadcrumb'

export default {
  components: {
    Breadcrumb
  },
  methods: {
    async logout() {
      await this.$store.dispatch('user/logout')
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.navbar .breadcrumb-container {
  float: left;
  margin-left: 20px;
}

.navbar .right-menu {
  float: right;
  height: 100%;
  line-height: 50px;
}

.navbar .right-menu:focus {
  outline: none;
}

.navbar .right-menu .right-menu-item {
  display: inline-block;
  padding: 0 8px;
  height: 100%;
  font-size: 18px;
  color: #5a5e66;
  vertical-align: text-bottom;
}

.navbar .right-menu .right-menu-item.hover-effect {
  cursor: pointer;
  transition: background 0.3s;
}

.navbar .right-menu .right-menu-item.hover-effect:hover {
  background: rgba(0, 0, 0, 0.025);
}

.navbar .right-menu .avatar-container {
  margin-right: 30px;
}

.navbar .right-menu .avatar-container .avatar-wrapper {
  margin-top: 5px;
  position: relative;
}

.navbar .right-menu .avatar-container .avatar-wrapper .user-avatar {
  cursor: pointer;
}

.navbar .right-menu .avatar-container .avatar-wrapper .el-icon-caret-bottom {
  cursor: pointer;
  position: absolute;
  right: -20px;
  top: 25px;
  font-size: 12px;
}
</style>
