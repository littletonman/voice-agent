import { Link } from 'react-router-dom';
import { Droplets, Calendar, Headphones } from 'lucide-react';

const features = [
  {
    icon: Droplets,
    title: 'Services Info',
    description:
      'Ask about our wash packages, pricing, and add-on services anytime.',
  },
  {
    icon: Calendar,
    title: 'Book Appointments',
    description:
      'Schedule your next wash with a quick voice conversation.',
  },
  {
    icon: Headphones,
    title: '24/7 Support',
    description:
      'Get instant answers to your questions around the clock.',
  },
];

export function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-2">
            <Droplets className="h-7 w-7 text-sky-600" />
            <span className="text-lg font-bold text-gray-900">
              Crystal Clear Car Wash
            </span>
          </div>
        </div>
      </header>

      {/* Hero */}
      <main className="flex-1">
        <section className="px-6 py-20 text-center">
          <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            Crystal Clear Car Wash
          </h1>
          <p className="mx-auto mt-4 max-w-lg text-lg text-gray-500">
            Your AI-powered car wash assistant
          </p>
          <Link
            to="/call"
            className="mt-8 inline-flex items-center gap-2 rounded-full bg-sky-600 px-8 py-4 text-lg font-semibold text-white shadow-lg transition-colors hover:bg-sky-700 focus:outline-none focus:ring-2 focus:ring-sky-500 focus:ring-offset-2"
          >
            <Headphones className="h-5 w-5" />
            Start a Call
          </Link>
        </section>

        {/* Features */}
        <section className="mx-auto max-w-5xl px-6 pb-20">
          <div className="grid gap-6 sm:grid-cols-3">
            {features.map((feature) => (
              <div
                key={feature.title}
                className="rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm"
              >
                <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-sky-100">
                  <feature.icon className="h-7 w-7 text-sky-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900">
                  {feature.title}
                </h3>
                <p className="mt-2 text-sm text-gray-500">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-gray-200 bg-white px-6 py-6 text-center text-sm text-gray-400">
        &copy; {new Date().getFullYear()} Crystal Clear Car Wash. All rights
        reserved.
      </footer>
    </div>
  );
}
