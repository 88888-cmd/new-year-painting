import { login, getInfo } from '@/api/admin'
import { setToken, removeToken } from '@/utils/auth'
import { resetRouter } from '@/router'

const getDefaultState = () => {
  return {
    info: {
      id: 0,
      username: '',
      is_super: 0
    }
  }
}

const state = getDefaultState()

const mutations = {
  RESET_STATE: (state) => {
    Object.assign(state, getDefaultState())
  },
  SET_INFO: (state, info) => {
    state.info = info
  }
}

const actions = {
  login({ commit }, userInfo) {
    const { username, password } = userInfo
    return new Promise((resolve, reject) => {
      login({ username: username.trim(), password: password }).then(response => {
        const { data } = response
        setToken(data.token)
        resolve()
      }).catch(error => {
        reject(error)
      })
    })
  },

  getInfo({ commit, state }) {
    return new Promise((resolve, reject) => {
      getInfo().then(response => {
        const { data } = response
        if (!data) {
          reject('验证失败，请重新登录。')
        }

        commit('SET_INFO', data)
        resolve(data)
      }).catch(error => {
        reject(error)
      })
    })
  },

  logout({ commit }) {
    return new Promise((resolve) => {
      commit('RESET_STATE')
      removeToken()
      resetRouter()
      resolve()
    })
  },

  resetToken({ commit }) {
    return new Promise(resolve => {
      removeToken()
      resolve()
    })
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}

