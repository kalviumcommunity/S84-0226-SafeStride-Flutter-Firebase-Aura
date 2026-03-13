import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'SafeStride Discover',
  description: 'Safety-focused route discovery'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
