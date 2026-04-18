import { useState, useCallback } from 'react';
import { Mic, MicOff } from 'lucide-react';
import { StatusIndicator } from './StatusIndicator';
import { TranscriptPanel, type TranscriptMessage } from './TranscriptPanel';

type AgentStatus = 'connecting' | 'listening' | 'thinking' | 'speaking';

export function VoiceAgent() {
  const [isActive, setIsActive] = useState(false);
  const [status, setStatus] = useState<AgentStatus>('connecting');
  const [messages, setMessages] = useState<TranscriptMessage[]>([]);

  const handleToggle = useCallback(() => {
    if (!isActive) {
      setIsActive(true);
      setStatus('connecting');
      // Placeholder: simulate connection then listening
      setTimeout(() => setStatus('listening'), 1500);
      setMessages((prev) => [
        ...prev,
        {
          role: 'agent',
          text: 'Hi! Welcome to Crystal Clear Car Wash. How can I help you today?',
          timestamp: new Date(),
        },
      ]);
    } else {
      setIsActive(false);
      setStatus('connecting');
      setMessages([]);
    }
  }, [isActive]);

  return (
    <div className="flex flex-col items-center gap-8">
      {/* Status */}
      <div className="flex items-center gap-3">
        {isActive && <StatusIndicator status={status} />}
        {!isActive && (
          <span className="text-sm text-gray-400">Press the mic to start</span>
        )}
      </div>

      {/* Mic Button */}
      <button
        onClick={handleToggle}
        className={`group relative flex h-28 w-28 items-center justify-center rounded-full shadow-lg transition-all duration-300 focus:outline-none ${
          isActive
            ? 'bg-red-500 hover:bg-red-600'
            : 'bg-sky-600 hover:bg-sky-700'
        }`}
        aria-label={isActive ? 'End call' : 'Start call'}
      >
        {/* Pulse ring when active */}
        {isActive && (
          <span className="absolute h-full w-full rounded-full bg-red-400 opacity-30 animate-[pulse-ring_2s_ease-out_infinite]" />
        )}
        {isActive ? (
          <MicOff className="h-10 w-10 text-white" />
        ) : (
          <Mic className="h-10 w-10 text-white" />
        )}
      </button>

      <p className="text-xs text-gray-400">
        {isActive ? 'Tap to end call' : 'Tap to start voice assistant'}
      </p>

      {/* Transcript */}
      <div className="w-full max-w-md">
        <TranscriptPanel messages={messages} />
      </div>
    </div>
  );
}
