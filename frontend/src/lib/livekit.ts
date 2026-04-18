export async function fetchLiveKitToken(
  roomName: string,
  participantName: string
): Promise<string> {
  const resp = await fetch(
    `${import.meta.env.VITE_LIVEKIT_TOKEN_URL || '/api/livekit-token'}?room=${roomName}&participant=${participantName}`
  );
  const data = await resp.json();
  return data.token;
}
