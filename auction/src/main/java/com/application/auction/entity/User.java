package com.application.auction.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.Set;
import java.util.UUID;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = "roles")
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @JdbcTypeCode(SqlTypes.CHAR)
    @EqualsAndHashCode.Include
    UUID id;

    String username;

    @Column(nullable = false)
    String password;

    @Column(nullable = false, unique = true)
    @EqualsAndHashCode.Include
    String email;

    @Column(unique = true)
    String phone;

    @Builder.Default
    @Column(nullable = false)
    boolean isActive = true;


    @ManyToMany(fetch = FetchType.LAZY)
    Set<Role> roles;

}
