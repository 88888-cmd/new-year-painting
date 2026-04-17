import request from '@/utils/request'

export function getList() {
  return request({
    url: '/posts/getList',
    method: 'get'
  })
}

export function detail(id) {
  return request({
    url: '/posts/detail',
    method: 'get',
    params: {
      posts_id: id
    }
  })
}

export function getCommentList(id) {
  return request({
    url: '/posts/getCommentList',
    method: 'get',
    params: {
      posts_id: id
    }
  })
}


export function del(id) {
  return request({
    url: '/posts/delete',
    method: 'post',
    data: {
      posts_id: id
    }
  })
}
