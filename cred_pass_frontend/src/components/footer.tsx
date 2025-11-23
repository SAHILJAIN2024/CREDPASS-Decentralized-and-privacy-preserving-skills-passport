export function Footer() {
  return (
    <footer className="py-6 px-4 sm:px-6 lg:px-8 border-t border-border/50">
      <div className="container mx-auto text-center text-muted-foreground text-sm">
        &copy; {new Date().getFullYear()} Cred-Pass. All rights reserved.
      </div>
    </footer>
  );
}