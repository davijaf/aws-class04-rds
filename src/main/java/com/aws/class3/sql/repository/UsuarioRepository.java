package com.aws.class3.sql.repository;

import com.aws.class3.sql.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}