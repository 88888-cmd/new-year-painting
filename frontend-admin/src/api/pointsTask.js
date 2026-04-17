import request from '@/utils/request'

export function getList() {
  return request({
    url: '/pointsTask/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/pointsTask/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/pointsTask/edit',
    method: 'post',
    data
  })
}

export function del(id) {
  return request({
    url: '/pointsTask/delete',
    method: 'post',
    data: {
      task_id: id
    }
  })
}

export function detail(id) {
  return request({
    url: '/pointsTask/detail',
    method: 'get',
    params: {
      task_id: id
    }
  })
}