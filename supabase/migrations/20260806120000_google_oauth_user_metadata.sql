-- Improve Google OAuth profile fields on auth.users INSERT.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_full_name text := trim(COALESCE(
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.raw_user_meta_data ->> 'name',
    ''
  ));
  v_first_name text := trim(COALESCE(
    NEW.raw_user_meta_data ->> 'given_name',
    NEW.raw_user_meta_data ->> 'first_name',
    NEW.raw_user_meta_data ->> 'firstname',
    CASE
      WHEN v_full_name <> '' THEN split_part(v_full_name, ' ', 1)
      ELSE ''
    END
  ));
  v_last_name text := trim(COALESCE(
    NEW.raw_user_meta_data ->> 'family_name',
    NEW.raw_user_meta_data ->> 'last_name',
    NEW.raw_user_meta_data ->> 'lastname',
    CASE
      WHEN v_full_name <> '' AND position(' ' in v_full_name) > 0
        THEN trim(substring(v_full_name from position(' ' in v_full_name) + 1))
      ELSE ''
    END
  ));
  v_user_name text := trim(COALESCE(
    NEW.raw_user_meta_data ->> 'user_name',
    NEW.raw_user_meta_data ->> 'preferred_username',
    NULLIF(v_first_name, ''),
    split_part(NEW.email, '@', 1)
  ));
  v_avatar text := trim(COALESCE(
    NEW.raw_user_meta_data ->> 'avatar_url',
    NEW.raw_user_meta_data ->> 'picture',
    NEW.raw_user_meta_data ->> 'profile_picture_url',
    ''
  ));
BEGIN
  INSERT INTO public.users (
    user_id,
    user_email,
    user_name,
    firstname,
    lastname,
    profile_picture_url,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    v_user_name,
    v_first_name,
    v_last_name,
    NULLIF(v_avatar, ''),
    now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    user_email = EXCLUDED.user_email,
    user_name = COALESCE(public.users.user_name, EXCLUDED.user_name),
    firstname = COALESCE(NULLIF(public.users.firstname, ''), EXCLUDED.firstname),
    lastname = COALESCE(NULLIF(public.users.lastname, ''), EXCLUDED.lastname),
    profile_picture_url = COALESCE(
      public.users.profile_picture_url,
      EXCLUDED.profile_picture_url
    );
  RETURN NEW;
END;
$$;
