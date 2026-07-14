-- Harden avatars bucket: remove broad public SELECT (bucket listing).

DROP POLICY IF EXISTS avatars_public_read ON storage.objects;

CREATE POLICY avatars_user_select ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
