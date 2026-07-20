export function notFoundHandler(req, res) {
  return res.status(404).json({
    code: 'NOT_FOUND',
    message: `Route ${req.method} ${req.originalUrl} was not found.`,
  });
}

export function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  const status = Number.isInteger(error?.status) ? error.status : 500;
  const code = error?.code || 'INTERNAL_ERROR';
  const message = error?.message || 'Unexpected server error.';

  if (status >= 500) {
    console.error('[ERROR]', error);
  }

  return res.status(status).json({
    code,
    message,
  });
}
