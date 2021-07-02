package uk.gov.hmcts.futurehearings.pip.acceptance.common.test;

import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.TestInfo;
import org.springframework.beans.factory.annotation.Autowired;
import uk.gov.hmcts.futurehearings.pip.acceptance.common.delegate.CommonDelegate;

@Slf4j
@Setter
@Getter
public abstract class PIPCommonTest {
    private String authorizationToken;

    @Autowired(required = false)
    public CommonDelegate commonDelegate;

    @BeforeAll
    public void beforeAll(TestInfo info) {
    }

    @BeforeEach
    public void beforeEach(TestInfo info) {
    }

    @AfterEach
    public void afterEach(TestInfo info) {
    }

    @AfterAll
    public void afterAll(TestInfo info) {
    }

}
