package config;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class Seguridad {

	private static final String ALGORITMO = "PBKDF2WithHmacSHA256";
	private static final String PREFIJO = "PBKDF2";
	private static final int ITERACIONES = 120000;
	private static final int BITS_CLAVE = 256;
	private static final int BYTES_SAL = 16;

	//Convierte la contraseña en un texto cifrado: PBKDF2$iteraciones$sal$hash
	public static String cifrar(String clave) {

		byte[] sal = new byte[BYTES_SAL];
		new SecureRandom().nextBytes(sal);

		return PREFIJO + "$" + ITERACIONES + "$" + Base64.getEncoder().encodeToString(sal)
				+ "$" + Base64.getEncoder().encodeToString(derivar(clave, sal, ITERACIONES));
	}

	//Compara la contraseña escrita con la que está guardada en la base de datos
	public static boolean verificar(String clave, String guardada) {

		if (clave == null || guardada == null) {
			return false;
		}

		String[] partes = guardada.split("\\$");

		if (partes.length != 4 || !PREFIJO.equals(partes[0])) {
			return false;
		}

		try {
			int iteraciones = Integer.parseInt(partes[1]);
			byte[] sal = Base64.getDecoder().decode(partes[2]);
			byte[] esperado = Base64.getDecoder().decode(partes[3]);

			return MessageDigest.isEqual(esperado, derivar(clave, sal, iteraciones));

		} catch (IllegalArgumentException e) {
			return false;
		}
	}

	private static byte[] derivar(String clave, byte[] sal, int iteraciones) {

		try {
			PBEKeySpec spec = new PBEKeySpec(clave.toCharArray(), sal, iteraciones, BITS_CLAVE);
			return SecretKeyFactory.getInstance(ALGORITMO).generateSecret(spec).getEncoded();

		} catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
			throw new IllegalStateException("No se pudo cifrar la contraseña.", e);
		}
	}
}