import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

const createChannel = (socket, topic, subtopic, userId) => socket.channel(
  [topic, subtopic].join(':'),
  { user_id: userId },
)

const joinChannel = (channel) => channel
  .join()
  .receive('ok', (reply) => console.log(`joined channel '${channel.topic}':`, reply))
  .receive('error', (reply) => console.log(`Unable to join '${channel.topic}':`, reply));

export {
  socket,
  createChannel,
  joinChannel,
};
