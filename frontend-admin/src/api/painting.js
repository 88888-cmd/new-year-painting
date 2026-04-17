import request from '@/utils/request'

export function getList() {
  return request({
    url: '/painting/getList',
    method: 'get'
  })
}

export function getFilterOptions() {
  return request({
    url: '/painting/getFilterOptions',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/painting/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/painting/edit',
    method: 'post',
    data
  })
}

export function detail(id) {
  return request({
    url: '/painting/detail',
    method: 'get',
    params: {
      painting_id: id
    }
  })
}


export function del(id) {
  return request({
    url: '/painting/delete',
    method: 'post',
    data: {
      painting_id: id
    }
  })
}
