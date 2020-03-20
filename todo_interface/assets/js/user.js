import { createChannel } from "./socket"

const createUserChannel = (socket, userId) => {
  const channel = createChannel(socket, 'user', userId, userId)
  channel.on('lists', ({lists}) => console.log('your lists', lists));
  return channel;
};

export {
  createUserChannel,
}
