import { animationFrames, Observable } from 'intween'
export const frames = (duration = 1000) => {
  return new Observable((observer) => {
    const sub = animationFrames().subscribe({
      next: (time) => {
        observer.next(time)
        if (time >= duration) {
          sub.unsubscribe()
          observer.next(duration)
          observer.complete()
        }
      },
      error: (error) => {
        observer.error(error)
      },
      complete: () => {
        observer.complete()
      }
    })
  })
}