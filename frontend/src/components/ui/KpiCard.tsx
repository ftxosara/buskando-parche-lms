import { LucideIcon } from 'lucide-react';
import clsx from 'clsx';

interface Props {
  label: string;
  value: string | number;
  icon: LucideIcon;
  color?: 'primary' | 'secondary' | 'success' | 'info';
  subtitle?: string;
}

const colorMap = {
  primary: 'bg-primary/10 text-primary border-primary/20',
  secondary: 'bg-secondary/10 text-secondary border-secondary/20',
  success: 'bg-success/10 text-success border-success/20',
  info: 'bg-info/10 text-info border-info/20',
};

export default function KpiCard({ label, value, icon: Icon, color = 'primary', subtitle }: Props) {
  return (
    <div className="card flex items-start gap-4 hover:border-surface-muted transition-colors duration-200">
      <div className={clsx('p-3 rounded-xl border', colorMap[color])}>
        <Icon className="w-6 h-6" />
      </div>
      <div>
        <p className="text-text-secondary text-sm">{label}</p>
        <p className="text-2xl font-bold font-display text-white mt-0.5">{value}</p>
        {subtitle && <p className="text-text-muted text-xs mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}
