import Link from 'next/link';
import { ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';

export function Header() {
  return (
    <header className="py-4 px-4 sm:px-6 lg:px-8 bg-transparent sticky top-0 z-50 backdrop-blur-sm bg-background/80 border-b border-border/50">
      <div className="container mx-auto flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <ShieldCheck className="h-8 w-8 text-primary" />
          <span className="text-2xl font-bold text-foreground">Cred-Pass</span>
        </Link>
        <nav className="hidden md:flex items-center gap-6">
          <Link
            href="/dashboard"
            className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            Dashboard
          </Link>
          <Link
            href="/dashboard/search"
            className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            Search
          </Link>
        </nav>
        <Button asChild>
          <Link href="/dashboard">Access Portal</Link>
        </Button>
      </div>
    </header>
  );
}