'use client';
import Link from 'next/link';
import { BookOpen, Lock, Users, CheckCircle, PlayCircle } from 'lucide-react';
import clsx from 'clsx';

interface Course {
  id: string;
  title: string;
  description: string;
  modality: string;
  formador: string;
  totalSessions: number;
  totalEnrolled: number;
  isEnrolled: boolean;
  enrollmentStatus: string | null;
}

export default function CourseCard({ course }: { course: Course }) {
  const isLocked = !course.isEnrolled;

  return (
    <div className={clsx(
      'card relative overflow-hidden transition-all duration-300 group',
      isLocked
        ? 'opacity-60 cursor-not-allowed'
        : 'hover:border-primary/40 hover:shadow-brand cursor-pointer hover:-translate-y-1'
    )}>
      {/* Top accent */}
      <div className={clsx(
        'absolute top-0 left-0 right-0 h-1',
        isLocked ? 'bg-surface-muted' : 'bg-gradient-brand'
      )} />

      <div className="flex items-start gap-4 pt-2">
        {/* Icon */}
        <div className={clsx(
          'p-3 rounded-xl flex-shrink-0',
          isLocked ? 'bg-surface-muted' : 'bg-primary/15 group-hover:bg-primary/25 transition-colors'
        )}>
          {isLocked
            ? <Lock className="w-6 h-6 text-text-muted" />
            : <BookOpen className="w-6 h-6 text-primary" />
          }
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <h3 className={clsx('font-semibold text-base leading-tight', isLocked ? 'text-text-muted' : 'text-white')}>
              {course.title}
            </h3>
            {course.isEnrolled && (
              <span className="badge-success flex-shrink-0">
                <CheckCircle className="w-3 h-3" /> Inscrito
              </span>
            )}
          </div>

          <p className={clsx('text-sm mt-1.5 line-clamp-2', isLocked ? 'text-text-muted' : 'text-text-secondary')}>
            {course.description}
          </p>

          <div className="flex items-center gap-4 mt-4 text-xs text-text-muted">
            <span className="flex items-center gap-1">
              <PlayCircle className="w-3.5 h-3.5" />
              {course.totalSessions} sesiones
            </span>
            <span className="flex items-center gap-1">
              <Users className="w-3.5 h-3.5" />
              {course.totalEnrolled} inscritos
            </span>
            <span className={clsx(
              'px-2 py-0.5 rounded-md font-medium',
              course.modality === 'VIRTUAL'
                ? 'bg-info/10 text-info'
                : 'bg-success/10 text-success'
            )}>
              {course.modality === 'VIRTUAL' ? 'Virtual' : 'Presencial'}
            </span>
          </div>

          <div className="flex items-center justify-between mt-4">
            <span className="text-xs text-text-muted">Formador: <span className="text-text-secondary">{course.formador}</span></span>
            {course.isEnrolled ? (
              <Link href={`/courses/${course.id}`} className="btn-primary py-2 px-4 text-sm">
                Acceder al curso
              </Link>
            ) : (
              <span className="text-xs text-text-muted flex items-center gap-1">
                <Lock className="w-3.5 h-3.5" /> Solo para inscritos
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
