type AgentStatus = 'connecting' | 'listening' | 'thinking' | 'speaking';

interface StatusIndicatorProps {
  status: AgentStatus;
}

const statusConfig: Record<AgentStatus, { color: string; pulseColor: string; label: string }> = {
  connecting: {
    color: 'bg-yellow-400',
    pulseColor: 'bg-yellow-400',
    label: 'Connecting...',
  },
  listening: {
    color: 'bg-green-500',
    pulseColor: 'bg-green-500',
    label: 'Listening',
  },
  thinking: {
    color: 'bg-blue-500',
    pulseColor: 'bg-blue-500',
    label: 'Thinking...',
  },
  speaking: {
    color: 'bg-sky-600',
    pulseColor: 'bg-sky-600',
    label: 'Speaking',
  },
};

export function StatusIndicator({ status }: StatusIndicatorProps) {
  const config = statusConfig[status];

  return (
    <div className="flex items-center gap-2">
      <span className="relative flex h-3 w-3">
        <span
          className={`absolute inline-flex h-full w-full animate-ping rounded-full opacity-75 ${config.pulseColor}`}
        />
        <span
          className={`relative inline-flex h-3 w-3 rounded-full ${config.color}`}
        />
      </span>
      <span className="text-sm font-medium text-gray-600">{config.label}</span>
    </div>
  );
}
