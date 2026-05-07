package com.sara.automation.utils;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Gestor thread-safe para asignar usuarios de forma concurrente
 * Mantiene un pool de usuarios disponibles y los asigna a cada thread de ejecución
 */
public class UserPoolManager {

    private static final ResourceBundle bundle = ResourceBundle.getBundle("credentials");
    private static final Map<Long, UserCredentials> threadUsers = new ConcurrentHashMap<>();
    private static final AtomicInteger currentUserIndex = new AtomicInteger(0);
    private static List<UserCredentials> availableUsers;
    private static final Object lock = new Object();

    static {
        loadUsers();
    }

    private UserPoolManager() {}

    /**
     * Carga todos los usuarios disponibles desde credentials.properties
     */
    private static void loadUsers() {
        availableUsers = new ArrayList<>();
        int userCount = 1;
        
        while (true) {
            String userKey = "usuario" + userCount;
            String passKey = "contrasena" + userCount;
            
            try {
                String usuario = bundle.getString(userKey);
                String contrasena = bundle.getString(passKey);
                availableUsers.add(new UserCredentials(usuario, contrasena, userCount));
                userCount++;
            } catch (MissingResourceException e) {
                // No hay más usuarios disponibles
                break;
            }
        }
        
        if (availableUsers.isEmpty()) {
            // Fallback: si no hay usuarios numerados, intenta con usuario/contrasena simples
            try {
                String usuario = bundle.getString("usuario");
                String contrasena = bundle.getString("contrasena");
                availableUsers.add(new UserCredentials(usuario, contrasena, 1));
            } catch (MissingResourceException e) {
                throw new RuntimeException("No se encontraron credenciales en credentials.properties");
            }
        }
        
        System.out.println("[UserPoolManager] =====================================");
        System.out.println("[UserPoolManager] Cargados " + availableUsers.size() + " usuarios disponibles");
        System.out.println("[UserPoolManager] Usuarios: pruebas1 - pruebas" + availableUsers.size());
        System.out.println("[UserPoolManager] Disponibles para asignación paralela");
        System.out.println("[UserPoolManager] =====================================");
    }

    /**
     * Obtiene un usuario específico basado en su número
     * Útil para asignar determinísticamente usuarios a runners específicos
     */
    public static UserCredentials getUserByNumber(int userNumber) {
        if (userNumber < 1 || userNumber > availableUsers.size()) {
            // Si el número está fuera de rango, usar round-robin estándar
            return getCredentialsForCurrentThread();
        }
        
        long threadId = Thread.currentThread().getId();
        String threadName = Thread.currentThread().getName();
        UserCredentials user = availableUsers.get(userNumber - 1); // userNumber es 1-indexed
        
        threadUsers.put(threadId, user);
        System.out.println("[UserPoolManager] Thread ID=" + threadId + " (Name=" + threadName + ") asignado a usuario específico: " + user.getUsuario() + " [Número: " + userNumber + "]");
        
        return user;
    }

    /**
     * Obtiene las credenciales asignadas al thread actual
     * Si el thread no tiene usuario asignado, le asigna uno del pool
     */
    public static UserCredentials getCredentialsForCurrentThread() {
        long threadId = Thread.currentThread().getId();
        String threadName = Thread.currentThread().getName();
        
        return threadUsers.computeIfAbsent(threadId, id -> {
            synchronized (lock) {
                // Asignar el siguiente usuario disponible (round-robin)
                int index = currentUserIndex.getAndIncrement() % availableUsers.size();
                UserCredentials user = availableUsers.get(index);
                System.out.println("[UserPoolManager] Thread ID=" + threadId + " (Name=" + threadName + ") asignado a usuario: " + user.getUsuario() + " [Índice: " + index + " de " + availableUsers.size() + "]");
                return user;
            }
        });
    }

    /**
     * Libera el usuario asignado al thread actual (opcional, para liberar recursos)
     */
    public static void releaseCurrentThreadUser() {
        long threadId = Thread.currentThread().getId();
        UserCredentials released = threadUsers.remove(threadId);
        if (released != null) {
            System.out.println("[UserPoolManager] Thread " + threadId + " liberó usuario: " + released.getUsuario());
        }
    }

    /**
     * Clase interna para almacenar credenciales de usuario
     */
    public static class UserCredentials {
        private final String usuario;
        private final String contrasena;
        private final int userNumber;

        public UserCredentials(String usuario, String contrasena, int userNumber) {
            this.usuario = usuario;
            this.contrasena = contrasena;
            this.userNumber = userNumber;
        }

        public String getUsuario() {
            return usuario;
        }

        public String getContrasena() {
            return contrasena;
        }

        public int getUserNumber() {
            return userNumber;
        }

        @Override
        public String toString() {
            return "Usuario: " + usuario + " (#" + userNumber + ")";
        }
    }

    /**
     * Obtiene el número total de usuarios disponibles
     */
    public static int getTotalUsers() {
        return availableUsers.size();
    }

    /**
     * Resetea el pool (útil para testing)
     */
    public static void reset() {
        threadUsers.clear();
        currentUserIndex.set(0);
    }
}
