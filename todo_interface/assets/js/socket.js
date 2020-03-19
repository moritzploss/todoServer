// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

const createChannel = (socket, subtopic, ownerId, topic = 'list') => {
  const channel = socket.channel(
    [topic, subtopic].join(':'),
    { owner_id: ownerId },
  )

  channel.on('list', (reply) => console.log('reply: ', reply))
  return channel;
};

const joinChannel = (channel) => channel
  .join()
  .receive('ok', (reply) => console.log(`joined channel '${channel.topic}':`, reply))
  .receive('error', (reply) => console.log(`Unable to join '${channel.topic}':`, reply));

const channel = createChannel(socket, 'foo', 'mo');
joinChannel(channel);

export default socket
