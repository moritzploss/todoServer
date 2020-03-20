import { createChannel } from "./socket"

const createListChannel = (socket, list_id, user_id) => {
  const channel = createChannel(socket, 'list', list_id, user_id)
  channel.on('list', (reply) => console.log('got list: ', reply))
  return channel;
};

export { createListChannel };
