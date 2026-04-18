import { Link } from 'react-router-dom';
import { ArrowLeft, Droplets } from 'lucide-react';
import { VoiceAgent } from '../components/VoiceAgent';

export function Call() {
  return (
    <div className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex max-w-5xl items-center gap-4 px-6 py-4">
          <Link
            to="/"
            className="flex items-center gap-1 text-sm text-gray-500 transition-colors hover:text-gray-900"
          >
            <ArrowLeft className="h-4 w-4" />
            Back
          </Link>
          <div className="flex items-center gap-2">
            <Droplets className="h-6 w-6 text-sky-600" />
            <span className="font-semibold text-gray-900">
              Crystal Clear Car Wash
            </span>
          </div>
        </div>
      </header>

      {/* Voice Agent */}
      <main className="flex flex-1 items-center justify-center px-6 py-12">
        <VoiceAgent />
      </main>
    </div>
  );
}
